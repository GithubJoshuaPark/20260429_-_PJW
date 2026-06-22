#!/bin/bash

# 1. 가상환경 활성화 (로컬 .venv 우선, 없으면 Conda logsentinel)
if [ -d ".venv" ]; then
    echo "[LogSentinel] Found local virtual environment (.venv). Activating..."
    source .venv/bin/activate
else
    echo "[LogSentinel] Local .venv not found. Searching for Conda environment..."
    CONDA_BASE=$(conda info --base 2>/dev/null || echo "/usr/local/anaconda3")
    if [ -f "$CONDA_BASE/etc/profile.d/conda.sh" ]; then
        source "$CONDA_BASE/etc/profile.d/conda.sh"
        conda activate logsentinel
    fi
fi

# 2. npx localtunnel 백그라운드 기동 및 주소 추출
# localtunnel 실행 출력을 임시 파일로 라우팅
LT_LOG=$(mktemp)
npx localtunnel --port 8000 > "$LT_LOG" 2>&1 &
LT_PID=$!

# 스크립트가 종료될 때(Ctrl+C 등) 백그라운드 localtunnel도 함께 클린업 종료
cleanup() {
    echo -e "\n[LogSentinel] Cleaning up localtunnel..."
    kill $LT_PID 2>/dev/null
    rm -f "$LT_LOG"
    exit 0
}
trap cleanup INT TERM EXIT

# 3. localtunnel 주소가 활성화될 때까지 최대 5초 대기
echo -n "[LogSentinel] Connecting to localtunnel service..."
LT_URL=""
for i in {1..10}; do
    sleep 0.5
    if grep -q "your url is:" "$LT_LOG"; then
        LT_URL=$(grep "your url is:" "$LT_LOG" | awk '{print $4}')
        echo " [OK]"
        break
    fi
    echo -n "."
done
if [ -z "$LT_URL" ]; then
    echo " [FAILED]"
fi

# 4. Spring Boot 스타일의 배너 및 기동 정보 출력
# ANSI Color Codes 적용 (Blue-Green 컨셉)
BLUE='\033[1;34m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
if [ -f "banner.txt" ]; then
    # banner.txt 내용을 읽어서 변수들을 치환한 뒤 출력
    sed -e "s/\${application.title}/LogSentinel/g" \
        -e "s/\${application.version}/1.0.0/g" \
        -e "s/Spring Boot \${spring-boot.version}/FastAPI \& PyTorch/g" \
        banner.txt
else
    echo "  _                  _____            _   _            _"
    echo " | |                / ____|          | | (_)          | |"
    echo " | |     ___   __ _| (___   ___ _ __ | |_ _ _ __   ___| |"
    echo " | |    / _ \ / _\` |\___ \ / _ \ '_ \| __| | '_ \ / _ \ |"
    echo " | |___| (_) | (_| |____) |  __/ | | | |_| | | | |  __/ |"
    echo " |______\___/ \__, |_____/ \___|_| |_|\__|_|_| |_|\___|_|"
    echo "               __/ |                                     "
    echo "              |___/                                      "
fi
echo -e "${NC}"

echo -e "========================================================================="
echo -e "  * ${GREEN}Local Swagger UI${NC} : http://127.0.0.1:8000/docs"
if [ -n "$LT_URL" ]; then
    echo -e "  * ${CYAN}Public Demo URL${NC}  : ${LT_URL}/docs"
else
    echo -e "  * ${CYAN}Public Demo URL${NC}  : localtunnel 접속 지연 (npx localtunnel 확인 필요)"
fi
echo -e "========================================================================="
echo ""

# 5. uvicorn 엔진으로 FastAPI 서버 가동
if command -v uvicorn &> /dev/null; then
    uvicorn src.main:app --port 8000 --reload
else
    # 활성화된 가상환경에 없거나 글로벌에 없는 경우 Conda fallback 시도
    if [ -z "$CONDA_PREFIX" ] && [ -n "$CONDA_BASE" ] && [ -f "$CONDA_BASE/etc/profile.d/conda.sh" ]; then
        exec conda run --no-capture-output -n logsentinel uvicorn src.main:app --port 8000 --reload
    else
        echo "[오류] uvicorn을 실행할 수 없습니다. 가상환경 또는 패키지 설치 여부를 확인해 주세요."
        exit 1
    fi
fi


