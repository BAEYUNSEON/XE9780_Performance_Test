#!/bin/bash
#
LOG_FILE="${TEST_HOME}/cutlass/sustained_gemm_$(date +%Y%m%d_%H%M).log"

DURATION=600
END_TIME=$(($(date +%s) + DURATION))

echo endtime:${END_TIME}

echo "Sustained GEMM Test Start: $(date)" | tee "${LOG_FILE}"
iteration=0

while [ $(date +%s) -lt ${END_TIME} ]; do
  iteration=$((iteration + 1))
  echo "" | tee -a "${LOG_FILE}"
  echo "==================================================" | tee -a "${LOG_FILE}"
  echo "--- Iteration ${iteration} [Remaining: $((${END_TIME} - $(date +%s)))s] ---" | tee -a "${LOG_FILE}"
  echo "==================================================" | tee -a "${LOG_FILE}"

  CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6 ./tools/profiler/cutlass_profiler \
    --kernels=gemm \
    --m=8192 --n=8192 --k=8192 \
    --A=f16:column --B=f16:row --C=f32:column \
    --warmup_count=2 \
    --iterations=10 \
    2>&1 | tee -a "${LOG_FILE}"
done

echo "Sustained GEMM Test End: $(date)" | tee -a "${LOG_FILE}"

