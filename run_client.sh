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

# 2. Python 3 엔진으로 모의 클라이언트 구동
if command -v python3 &> /dev/null; then
    python3 ./src/test_client.py
else
    # Conda run fallback
    if [ -n "$CONDA_BASE" ] && [ -f "$CONDA_BASE/etc/profile.d/conda.sh" ]; then
        exec conda run --no-capture-output -n logsentinel python3 ./src/test_client.py
    else
        echo "[오류] python3을 실행할 수 없습니다."
        exit 1
    fi
fi