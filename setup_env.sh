#!/bin/bash

# setup_env.sh
# 최종 과제 제출용 로컬 가상환경(.venv) 셋업 및 의존성 설치 스크립트

echo "=========================================================="
echo " LogSentinel: 가상환경 셋업 및 패키지 설치를 시작합니다."
echo "=========================================================="

# 1. 파이썬 설치 여부 확인
if ! command -v python3 &> /dev/null; then
    echo "[오류] python3이 시스템에 설치되어 있지 않습니다. 파이썬을 먼저 설치해 주세요."
    exit 1
fi

# 2. 가상환경 생성
if [ ! -d ".venv" ]; then
    echo "[정보] 로컬 가상환경(.venv)을 생성합니다..."
    python3 -m venv .venv
    if [ $? -ne 0 ]; then
        echo "[오류] 가상환경 생성에 실패했습니다."
        exit 1
    fi
    echo "[성공] 가상환경이 생성되었습니다."
else
    echo "[정보] 기존 가상환경(.venv)이 존재합니다."
fi

# 3. 가상환경 활성화 및 패키지 설치
echo "[정보] 가상환경을 활성화하고 의존성 패키지를 설치합니다..."
source .venv/bin/activate

# pip 업그레이드
pip install --upgrade pip

# requirements.txt 설치
if [ -f "requirements.txt" ]; then
    echo "[정보] requirements.txt 패키지를 설치합니다. (시간이 다소 소요될 수 있습니다)"
    pip install -r requirements.txt
    if [ $? -eq 0 ]; then
        echo "[성공] 모든 의존성 패키지가 정상적으로 설치되었습니다."
    else
        echo "[오류] 패키지 설치 중 문제가 발생했습니다."
        exit 1
    fi
else
    echo "[오류] requirements.txt 파일을 찾을 수 없습니다."
    exit 1
fi

echo "=========================================================="
echo " 셋업이 완료되었습니다. 다음 명령어로 서버를 구동할 수 있습니다:"
echo " ./run_server.sh"
echo "=========================================================="
