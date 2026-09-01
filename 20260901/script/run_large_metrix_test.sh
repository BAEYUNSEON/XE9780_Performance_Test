#!/bin/bash
#

LOG_DATE=$(date +%Y%m%d_%H%M)
LOG_FILE="${TEST_HOME}/cutlass/large_matrix_${LOG_DATE}.log"

for gpu_id in 0 1 2 3 4 5 6; do
  echo "=========================================" | tee -a "${LOG_FILE}"
  echo "===== GPU ${gpu_id} Large Matrix GEMM =====" | tee -a "${LOG_FILE}"
  echo "=========================================" | tee -a "${LOG_FILE}"

  # 대형 행렬이므로 연산 시간 확보를 위해 iterations는 10회로 적절히 유지되었습니다.
  CUDA_VISIBLE_DEVICES=${gpu_id} ./tools/profiler/cutlass_profiler \
    --kernels=gemm \
    --m=32768 --n=32768 --k=32768 \
    --A=f16:column --B=f16:row --C=f32:column \
    --warmup_count=3 \
    --iterations=10 \
    2>&1 | tee -a "${LOG_FILE}"

  echo -e "\n\n" | tee -a "${LOG_FILE}"
done

echo "Large Matrix Deviation Test Finished: $(date)"
