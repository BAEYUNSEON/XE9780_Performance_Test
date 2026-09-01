#!/bin/bash
#
LOG_DATE=$(date +%Y%m%d_%H%M)
LOG_FILE="${TEST_HOME}/gpu_burn/gpuburn24h_${LOG_DATE}.log"

echo "GPU Burn-in 8 Hours Test Started at $(date)" | tee "${LOG_FILE}"

# 2. 7대 GPU 전부에 8시간(28800초) 동안 과부하 실행 및 로그 누적
CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6 ./gpu_burn 86400 2>&1 | tee -a "${LOG_FILE}"

echo "GPU Burn-in 8 Hours Test Finished at $(date)" | tee -a "${LOG_FILE}"

