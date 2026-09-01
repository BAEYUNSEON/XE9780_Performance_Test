#!/bin/bash
#
LOG_DATE=$(date +%Y%m%d_%H%M)

DURATION=600  # 10분(600초) 동안 지속
END_TIME=$(($(date +%s) + DURATION))

echo "Multi-GPU Core + Memory Concurrent Sustained Test Started: $(date)"

iteration=0
while [ $(date +%s) -lt ${END_TIME} ]; do
  iteration=$((iteration + 1))
  echo "--- Iteration ${iteration} [Remaining: $((${END_TIME} - $(date +%s)))s] ---"

  # 0번부터 6번 GPU까지 순회하며 두 가지 부하를 동시에 투하
  for gpu_id in 0 1 2 3 4 5 6; do

    # A. [코어 연산 부하] CUTLASS 프로파일러 (백그라운드)
    CUDA_VISIBLE_DEVICES=${gpu_id} ./tools/profiler/cutlass_profiler \
      --kernels=gemm \
      --m=16384 --n=16384 --k=16384 \
      --A=f16:column --B=f16:row --C=f32:column \
      --warmup_count=5 \
      --iterations=50 \
      2>&1 >> "${TEST_HOME}/cutlass/gemm_memread_gpu${gpu_id}_${LOG_DATE}.log" &

    # B. [메모리 대역폭 부하] 🔥 말씀하신 BabelStream 구문 정상 탑재 (백그라운드)
    CUDA_VISIBLE_DEVICES=${gpu_id} ~/BabelStream/build/cuda-stream \
      --arraysize $((1024*1024*256)) \
      --numtimes 100 \
      2>&1 >> "${TEST_HOME}/cutlass/memread_gpu${gpu_id}_${LOG_DATE}.log" &

  done

  # [핵심 안전장치] 7대 GPU에서 위의 14개(7대 × 2개 프로그램) 백그라운드 프로세스가
  # 모두 끝날 때까지 기다린 후 다음 바퀴(Iteration)를 돕니다. (폭주 방지)
  wait

  # 컨텍스트 정리를 위한 1초 미세 휴식
  sleep 1
done

echo "Multi-GPU Concurrent Sustained Test Ended: $(date)"
