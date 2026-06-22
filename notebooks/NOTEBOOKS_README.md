# LogSentinel 노트북 디렉토리(./notebooks/) 개요 및 파일별 역할 명세

본 문서는 `LogSentinel` 프로젝트의 실험 및 모델 개발 단계에서 활용된 주피터 노트북 파일(`.ipynb`)들의 핵심 역할과 담당 단계를 기술한 명세서입니다.

---

## 1. 노트북 파일별 역할 명세 요약 표

| 파일명 | 개발 단계 및 영역 | 파일 설명 및 핵심 역할 |
| :--- | :--- | :--- |
| **`01_eda_preprocessing.ipynb`** | [1~2단계] EDA & 전처리 | BGL 로그 탐색(EDA) 및 정규표현식 기반의 노이즈 정제 규칙 파이프라인 개발 |
| **`02_anomaly_detection.ipynb`** | [3단계] 이상 감지 프로토타입 | Isolation Forest 비지도 학습 튜닝 및 contamination 파라미터별 혼동행렬 스캔 |
| **`03_deep_learning_model.ipynb`** | [4단계] 딥러닝 장애 분류 | PyTorch LSTM/GRU 신경망 설계, Class Weight를 활용한 불균형 학습 및 F1-Score 측정 |

---

## 2. 노트북별 세부 구현 사항 및 분석 내용

### 1) [01_eda_preprocessing.ipynb](file:///Users/joshuapark/Desktop/Dev/soromiso/LogSentinel/notebooks/01_eda_preprocessing.ipynb)
* **목적**: 원본 로그 파일의 구조를 규명하고 텍스트 노이즈를 정형화합니다.
* **주요 수행 작업**:
  - BGL 로그의 특징(총 행수, 정상 `-` 비율, 에러 카테고리 종류 등) 파악.
  - IP 주소, 16진수 메모리 주소, DateTime, Node 아이디, 일반 숫자 등을 특수 태그 토큰(예: `[IP]`, `[HEX]`, `[NUM]`)으로 치환하는 정규표현식 규칙 설계.
  - 정제된 단어 셋을 기반으로 TF-IDF Vectorizer를 적합(Fit)시켜 로그를 500차원 벡터로 변환하는 기초 프로세스 수립.

### 2) [02_anomaly_detection.ipynb](file:///Users/joshuapark/Desktop/Dev/soromiso/LogSentinel/notebooks/02_anomaly_detection.ipynb)
* **목적**: 비지도 학습 이상 탐지(Anomaly Detection) 모델의 초기 탐지 경향성을 검증합니다.
* **주요 수행 작업**:
  - `BGL_2k.log` 샘플을 기준으로 Isolation Forest 알고리즘의 오염도(`contamination`) 파라미터 스캔 (`0.01` ~ `0.15`).
  - 각 파라미터 조건에서의 Confusion Matrix(진짜양성, 가짜양성 등) 및 ROC-AUC 스코어를 파일로 기록 및 Matplotlib 시각화.
  - 비지도 이상 감지의 미탐/오탐 한계를 고찰하고, 실시간 추론 연계를 위한 프로토타입 생성.

### 3) [03_deep_learning_model.ipynb](file:///Users/joshuapark/Desktop/Dev/soromiso/LogSentinel/notebooks/03_deep_learning_model.ipynb)
* **목적**: 이상이 감지된 로그들에 대한 장애 클래스 다중 분류(Multi-class Classification) 모델을 구축합니다.
* **주요 수행 작업**:
  - 정제 로그 텍스트를 과거 5개~10개 시퀀스로 묶어 다차원 시계열 텐서(Tensor) 구성.
  - PyTorch 기반 LSTM 네트워크 설계 (입력 차원 500, 은닉 차원 64, 출력 클래스 3: ALERT, FATAL, WARNING).
  - 극심한 클래스 불균형에 대응하기 위해 가중 손실 함수(`Weighted Cross Entropy Loss`)를 도입하여 학습 효율성 향상.
  - 검증 데이터셋에 대한 Precision, Recall, F1-Score를 상세 산출하고 학습 완료 가중치(`models/lstm_model.pth`)를 디스크에 저장.
