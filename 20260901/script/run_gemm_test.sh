#!/bin/bash
#

LOG_DATE=$(date +%Y%m%d_%H%M)
LOG_FILE="${TEST_HOME}/cutlass/gemm_peak_${LOG_DATE}.log"

for gpu_id in 0 1 2 3 4 5 6; do
  echo "=========================================" | tee -a "${LOG_FILE}"
  echo "===== GPU ${gpu_id} GEMM Peak Test =====" | tee -a "${LOG_FILE}"
  echo "=========================================" | tee -a "${LOG_FILE}"

  # 개별 GPU를 하나씩 매핑하여 독립 테스트 유도
  CUDA_VISIBLE_DEVICES=${gpu_id} ./tools/profiler/cutlass_profiler \
    --kernels=gemm \
    --m=8192 --n=8192 --k=8192 \
    --A=f16:column --B=f16:row --C=f32:column \
    --warmup_count=5 \
    --iterations=20 \
    2>&1 | tee -a "${LOG_FILE}"
done
