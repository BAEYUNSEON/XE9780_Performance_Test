#!/bin/bash
#
LOG_FILE="${TEST_HOME}/cutlass/sustained_gemm_parallel_$(date +%Y%m%d_%H%M).log"

DURATION=600  # 10분
END_TIME=$(($(date +%s) + DURATION))

echo "Multi-GPU Sustained Test Started: $(date)" | tee ${LOG_FILE}

# 정해진 시간 동안 무한 실행
while [ $(date +%s) -lt ${END_TIME} ]; do

  # [핵심] 0번부터 6번까지 각각 백그라운드(&)로 동시에 독립 실행을 쏩니다.
  for gpu_id in 0 1 2 3 4 5 6; do
    CUDA_VISIBLE_DEVICES=${gpu_id} ./tools/profiler/cutlass_profiler \
      --kernels=gemm \
      --m=8192 --n=8192 --k=8192 \
      --A=f16:column --B=f16:row --C=f32:column \
      --warmup_count=2 \
      --iterations=20 > /dev/null 2>&1 &
  done

  # 7대 GPU가 한 사이클(20번 연산)을 마칠 때까지 약 1~2초간 대기 후 다시 루프
  sleep 1.5
done

# 실행 중인 잔여 테스트 프로세스 깔끔하게 종료 정리
killall cutlass_profiler 2>/dev/null
echo "Multi-GPU Sustained Test Ended: $(date)" | tee -a ${LOG_FILE}
