#!/bin/bash
#
LOG_DATE=$(date +%Y%m%d_%H%M)
LOG_FILE="${TEST_HOME}/babelstream/stream_bench_${LOG_DATE}.log"

for gpu_id in 0 1 2 3 4 5 6; do
  echo "=========================================" | tee -a "${LOG_FILE}"
  echo "===== GPU ${gpu_id} Stream Benchmark =====" | tee -a "${LOG_FILE}"
  echo "=========================================" | tee -a "${LOG_FILE}"

  # 안전장치 및 512MB 대용량 배열 설정 구동
  CUDA_VISIBLE_DEVICES=${gpu_id} ./cuda-stream \
    --arraysize $((1024*1024*512)) \
    --numtimes 100 \
    2>&1 | tee -a "${LOG_FILE}"

  echo -e "\n\n" | tee -a "${LOG_FILE}"
done
