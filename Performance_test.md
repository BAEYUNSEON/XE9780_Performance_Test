# Power Edge XE9780 Server Performance Test - 8/31 
## Phase 2 — Performance Test (8/31)

### 2.3  GPU 행렬연산 - Compute 
- **목적:** GPU 행렬연산 Compute(TFLOPS) 장시간 행렬연산의 처리능력(TFLOPS)이 정확한지 측정 .gpu_burn 로그 자체에 Gflop/s 가 출력

**Output**
``` bash
dell@dell:~$ cd gpu_burn
dell@dell:~/gpu_burn$ DUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6 ./gpu_burn -d 600 2>&1 | tee ~/gpu_burn_test/compute_$(date +%Y%m%d_%H%M).log
GPU 0: NVIDIA B300 SXM6 AC (UUID: GPU-bce5282f-d716-d136-5759-b7181a7a55df)
GPU 1: NVIDIA B300 SXM6 AC (UUID: GPU-d6fcaafa-e017-734b-43a5-9f5953cf7150)
GPU 2: NVIDIA B300 SXM6 AC (UUID: GPU-63702342-9bed-efb1-1262-10971a1218cd)
GPU 3: NVIDIA B300 SXM6 AC (UUID: GPU-50db20c5-bd33-c81d-2eea-d6f6b623c0f4)
GPU 4: NVIDIA B300 SXM6 AC (UUID: GPU-fa889c02-065e-66b6-15a8-e052e6fe3743)
GPU 5: NVIDIA B300 SXM6 AC (UUID: GPU-1ba19bc3-3adc-acaf-5b88-5c623b05a799)
GPU 6: NVIDIA B300 SXM6 AC (UUID: GPU-07634869-498e-829a-ecb5-9f1611c125fb)
cuInit returned 0 (no error)
cuInit returned 0 (no error)
cuInit returned 0 (no error)
cuInit returned 0 (no error)
cuInit returned 0 (no error)
cuInit returned 0 (no error)
cuInit returned 0 (no error)



Using compare file: compare.fatbin
Burning for 600 seconds.
84.5%  proc'd: 0 (0 Gflop/s) - 478 (1038 Gflop/s) - 0 (0 Gflop/s) - 0 (0 Gflop/s) - 0 (0 Gflop/s) - 0 (0 Gflop/s) - 0 (0 Gflop/s)   errors: 0 - 0 - 0 - 0 - 0 - 0 - 0   temps: 33 C - 48 C - 43 C - 34 C - 50 C - 34 C - 46 C
        Summary at:   Mon Aug 31 12:23:45 AM UTC 2026

Killing processes with SIGKILL (force kill)
done

Tested 7 GPUs:
        GPU 0: OK
        GPU 1: OK
        GPU 2: OK
        GPU 3: OK
        GPU 4: OK
        GPU 5: OK
        GPU 6: OK
```


### 2.4  HBM 메모리 대역폭(GB/s)  
- **목적:** HBM3e의 Read/Write/Add/Scale/Copy등 대역폭이 스펙(B300 이론상 약 8TB/s) 대비 정상 범위인지 측정

**installation**
```bash
dell@dell:~$ git clone https://github.com/NVIDIA/cuda-samples.git
Cloning into 'cuda-samples'...
remote: Enumerating objects: 31872, done.
remote: Counting objects: 100% (7352/7352), done.
remote: Compressing objects: 100% (441/441), done.
remote: Total 31872 (delta 6966), reused 6911 (delta 6911), pack-reused 24520 (from 2)
Receiving objects: 100% (31872/31872), 137.28 MiB | 6.34 MiB/s, done.
Resolving deltas: 100% (27705/27705), done.
```

**nvcc 환경변수 설정**
```bash
dell@dell:~/nvbandwidth$ export PATH=/usr/local/cuda/bin:$PATH
dell@dell:~/nvbandwidth$ export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
dell@dell:~/nvbandwidth$ echo 'export PATH=/usr/local/cuda/bin$PATH' >> ~/.bashrc
dell@dell:~/nvbandwidth$
dell@dell:~/nvbandwidth$
dell@dell:~/nvbandwidth$
dell@dell:~/nvbandwidth$
dell@dell:~/nvbandwidth$  echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
dell@dell:~/nvbandwidth$ echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
dell@dell:~/nvbandwidth$
dell@dell:~/nvbandwidth$
dell@dell:~/nvbandwidth$
dell@dell:~/nvbandwidth$ source ~/.bashrc
dell@dell:~/nvbandwidth$
dell@dell:~/nvbandwidth$
dell@dell:~/nvbandwidth$ which nvcc
/usr/local/cuda/bin/nvcc
dell@dell:~/nvbandwidth$ nvcc --version
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2026 NVIDIA Corporation
Built on Tue_Jun_09_02:43:40_PM_PDT_2026
Cuda compilation tools, release 13.3, V13.3.73
Build cuda_13.3.r13.3/compiler.38244171_0

```

**output**
```bash
dell@dell:~/nvbandwidth$ rm -rf build
dell@dell:~/nvbandwidth$
dell@dell:~/nvbandwidth$
dell@dell:~/nvbandwidth$
dell@dell:~/nvbandwidth$ cmake -B build \
  -DCMAKE_CUDA_COMPILER=$(which nvcc) \
  -DCMAKE_CUDA_ARCHITECTURES=86
-- CMAKE_CUDA_ARCHITECTURES set by user: 86
-- The CUDA compiler identification is NVIDIA 13.3.73
-- The CXX compiler identification is GNU 13.3.0
-- Detecting CUDA compiler ABI info
-- Detecting CUDA compiler ABI info - done
-- Check for working CUDA compiler: /usr/local/cuda/bin/nvcc - skipped
-- Detecting CUDA compile features
-- Detecting CUDA compile features - done
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/c++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Performing Test NVBW_HAVE_NVML_CONF_COMPUTE_SETTINGS
-- Performing Test NVBW_HAVE_NVML_CONF_COMPUTE_SETTINGS - Success
CMake Warning (dev) at /usr/share/cmake-3.28/Modules/FetchContent.cmake:1331 (message):
  The DOWNLOAD_EXTRACT_TIMESTAMP option was not given and policy CMP0135 is
  not set.  The policy's OLD behavior will be used.  When using a URL
  download, the timestamps of extracted files should preferably be that of
  the time of extraction, otherwise code that depends on the extracted
  contents might not be rebuilt if the URL changes.  The OLD behavior
  preserves the timestamps from the archive instead, but this is usually not
  what you want.  Update your project to the NEW behavior or specify the
  DOWNLOAD_EXTRACT_TIMESTAMP option with a value of true to avoid this
  robustness issue.
Call Stack (most recent call first):
  CMakeLists.txt:76 (FetchContent_Declare)
This warning is for project developers.  Use -Wno-dev to suppress it.

-- Configuring done (5.0s)
-- Generating done (0.0s)
-- Build files have been written to: /home/dell/nvbandwidth/build
dell@dell:~/nvbandwidth$ cmake --build build -j$(nproc)
[ 14%] Building CXX object CMakeFiles/nvbandwidth.dir/environment.cpp.o
[ 14%] Building CXX object CMakeFiles/nvbandwidth.dir/cuda_version_check.cpp.o
[ 21%] Building CXX object CMakeFiles/nvbandwidth.dir/testcases.cpp.o
[ 35%] Building CUDA object CMakeFiles/nvbandwidth.dir/kernels.cu.o
[ 35%] Building CXX object CMakeFiles/nvbandwidth.dir/testcase.cpp.o
[ 42%] Building CXX object CMakeFiles/nvbandwidth.dir/multinode_memcpy.cpp.o
[ 50%] Building CXX object CMakeFiles/nvbandwidth.dir/memcpy.cpp.o
[ 57%] Building CXX object CMakeFiles/nvbandwidth.dir/nvbandwidth.cpp.o
[ 64%] Building CXX object CMakeFiles/nvbandwidth.dir/multinode_testcases.cpp.o
[ 71%] Building CXX object CMakeFiles/nvbandwidth.dir/json_output.cpp.o
[ 78%] Building CXX object CMakeFiles/nvbandwidth.dir/output.cpp.o
[ 85%] Building CXX object CMakeFiles/nvbandwidth.dir/json/jsoncpp.cpp.o
[ 92%] Building CXX object CMakeFiles/nvbandwidth.dir/perf_parser_output.cpp.o
[100%] Linking CXX executable nvbandwidth
[100%] Built target nvbandwidth
dell@dell:~/nvbandwidth$
dell@dell:~/nvbandwidth$
dell@dell:~/nvbandwidth$ ls
build                   cuda_version_check.h    environment.h     json_output.h  memcpy.cpp               nvbandwidth.cpp           perf_parser_output.h  test_settings.h
CHANGELOG.md            debian_install.sh       error_handling.h  kernels.cu     memcpy.h                 nvbandwidth_version.h.in  README.md             troubleshooting.md
CMakeLists.txt          detect_cuda_arch.cmake  inline_common.h   kernels.cuh    multinode_memcpy.cpp     output.cpp                testcase.cpp
common.h                diagrams                json              LICENSE        multinode_memcpy.h       output.h                  testcase.h
cuda_version_check.cpp  environment.cpp         json_output.cpp   Licenses.txt   multinode_testcases.cpp  perf_parser_output.cpp    testcases.cpp
dell@dell:~/nvbandwidth$ cd build/
dell@dell:~/nvbandwidth/build$ ls
CMakeCache.txt  CMakeFiles  cmake_install.cmake  CPackConfig.cmake  CPackSourceConfig.cmake  _deps  Makefile  nvbandwidth  nvbandwidth_version.h
dell@dell:~/nvbandwidth/build$ ./nvbandwidth --version
nvbandwidth Version: v0.10.0
Built from Git version: v0.10

dell@dell:~/nvbandwidth/build$ ./nvbandwidth --list
nvbandwidth Version: v0.10.0
Built from Git version: v0.10

Index, Name:
        Description
0, host_to_device_memcpy_ce:
                Host to device CE memcpy using cuMemcpyAsync
1, device_to_host_memcpy_ce:
                Device to host CE memcpy using cuMemcpyAsync
2, host_to_device_bidirectional_memcpy_ce:
                A host to device copy is measured while a device to host copy is run simultaneously.
        Only the host to device copy bandwidth is reported.
3, device_to_host_bidirectional_memcpy_ce:
                A device to host copy is measured while a host to device copy is run simultaneously.
        Only the device to host copy bandwidth is reported.
4, device_to_device_memcpy_read_ce:
                Measures bandwidth of cuMemcpyAsync between each pair of accessible peers.
        Read tests launch a copy from the peer device to the target using the target's context.
5, device_to_device_memcpy_write_ce:
                Measures bandwidth of cuMemcpyAsync between each pair of accessible peers.
        Write tests launch a copy from the target device to the peer using the target's context.
6, device_to_device_bidirectional_memcpy_read_ce:
                Measures bandwidth of cuMemcpyAsync between each pair of accessible peers.
        A copy in the opposite direction of the measured copy is run simultaneously but not measured.
        Read tests launch a copy from the peer device to the target using the target's context.
7, device_to_device_bidirectional_memcpy_write_ce:
                Measures bandwidth of cuMemcpyAsync between each pair of accessible peers.
        A copy in the opposite direction of the measured copy is run simultaneously but not measured.
        Write tests launch a copy from the target device to the peer using the target's context.
8, all_to_host_memcpy_ce:
                Measures bandwidth of cuMemcpyAsync between a single device and the host while simultaneously
        running copies from all other devices to the host.
9, all_to_host_bidirectional_memcpy_ce:
                A device to host copy is measured while a host to device copy is run simultaneously.
        Only the device to host copy bandwidth is reported.
        All other devices generate simultaneous host to device and device to host interfering traffic.
10, host_to_all_memcpy_ce:
                Measures bandwidth of cuMemcpyAsync between the host to a single device while simultaneously
        running copies from the host to all other devices.
11, host_to_all_bidirectional_memcpy_ce:
                A host to device copy is measured while a device to host copy is run simultaneously.
        Only the host to device copy bandwidth is reported.
        All other devices generate simultaneous host to device and device to host interfering traffic.
12, all_to_one_write_ce:
                Measures the total bandwidth of copies from all accessible peers to a single device, for each
        device. Bandwidth is reported as the total inbound bandwidth for each device.
        Write tests launch a copy from the target device to the peer using the target's context.
13, all_to_one_read_ce:
                Measures the total bandwidth of copies from all accessible peers to a single device, for each
        device. Bandwidth is reported as the total outbound bandwidth for each device.
        Read tests launch a copy from the peer device to the target using the target's context.
14, one_to_all_write_ce:
                Measures the total bandwidth of copies from a single device to all accessible peers, for each
        device. Bandwidth is reported as the total outbound bandwidth for each device.
        Write tests launch a copy from the target device to the peer using the target's context.
15, one_to_all_read_ce:
                Measures the total bandwidth of copies from a single device to all accessible peers, for each
        device. Bandwidth is reported as the total inbound bandwidth for each device.
        Read tests launch a copy from the peer device to the target using the target's context.
16, host_to_device_memcpy_sm:
                Host to device SM memcpy using a copy kernel
17, device_to_host_memcpy_sm:
                Device to host SM memcpy using a copy kernel
18, host_to_device_bidirectional_memcpy_sm:
                A host to device copy is measured while a device to host copy is run simultaneously.
        Only the host to device copy bandwidth is reported.
19, device_to_host_bidirectional_memcpy_sm:
                A device to host copy is measured while a host to device copy is run simultaneously.
        Only the device to host copy bandwidth is reported.
20, device_to_device_memcpy_read_sm:
                Measures bandwidth of a copy kernel between each pair of accessible peers.
        Read tests launch a copy from the peer device to the target using the target's context.
21, device_to_device_memcpy_write_sm:
                Measures bandwidth of a copy kernel between each pair of accessible peers.
        Write tests launch a copy from the target device to the peer using the target's context.
22, device_to_device_bidirectional_memcpy_read_sm:
                Measures bandwidth of a copy kernel between each pair of accessible peers. Copies are run
        in both directions between each pair, and the sum is reported.
        Read tests launch a copy from the peer device to the target using the target's context.
23, device_to_device_bidirectional_memcpy_write_sm:
                Measures bandwidth of a copy kernel between each pair of accessible peers. Copies are run
        in both directions between each pair, and the sum is reported.
        Write tests launch a copy from the target device to the peer using the target's context.
24, all_to_host_memcpy_sm:
                Measures bandwidth of a copy kernel between a single device and the host while simultaneously
        running copies from all other devices to the host.
25, all_to_host_bidirectional_memcpy_sm:
                A device to host bandwidth of a copy kernel is measured while a host to device copy is run simultaneously.
        Only the device to host copy bandwidth is reported.
        All other devices generate simultaneous host to device and device to host interfering traffic using copy kernels.
26, host_to_all_memcpy_sm:
                Measures bandwidth of a copy kernel between the host to a single device while simultaneously
        running copies from the host to all other devices.
27, host_to_all_bidirectional_memcpy_sm:
                A host to device bandwidth of a copy kernel is measured while a device to host copy is run simultaneously.
        Only the host to device copy bandwidth is reported.
        All other devices generate simultaneous host to device and device to host interfering traffic using copy kernels.
28, all_to_one_write_sm:
                Measures the total bandwidth of copies from all accessible peers to a single device, for each
        device. Bandwidth is reported as the total inbound bandwidth for each device.
        Write tests launch a copy from the target device to the peer using the target's context.
29, all_to_one_read_sm:
                Measures the total bandwidth of copies from all accessible peers to a single device, for each
        device. Bandwidth is reported as the total outbound bandwidth for each device.
        Read tests launch a copy from the peer device to the target using the target's context.
30, one_to_all_write_sm:
                Measures the total bandwidth of copies from a single device to all accessible peers, for each
        device. Bandwidth is reported as the total outbound bandwidth for each device.
        Write tests launch a copy from the target device to the peer using the target's context.
31, one_to_all_read_sm:
                Measures the total bandwidth of copies from a single device to all accessible peers, for each
        device. Bandwidth is reported as the total inbound bandwidth for each device.
        Read tests launch a copy from the peer device to the target using the target's context.
32, host_device_latency_sm:
                Host - device access latency using a pointer chase kernel
        A 2MB buffer is allocated on the host and is accessed by the GPU
33, device_to_device_latency_sm:
                Measures latency of a pointer derefernce operation between each pair of accessible peers.
        A 2MB buffer is allocated on a GPU and is accessed by the peer GPU to determine latency.
        --bufferSize flag is ignored
34, device_to_device_memcpy_read_tma:
                Measures bandwidth of TMA copies between each pair of accessible peers.
        Read tests launch a copy from the peer device to the target using the target's context.
35, device_to_device_memcpy_write_tma:
                Measures bandwidth of TMA copies between each pair of accessible peers.
        Write tests launch a copy from the target device to the peer using the target's context.
36, device_to_device_bidirectional_memcpy_read_tma:
                Measures bandwidth of TMA bidirectional copies between each pair of accessible peers.
        Read tests launch a copy from the peer device to the target using the target's context.
37, device_to_device_bidirectional_memcpy_write_tma:
                Measures bandwidth of TMA bidirectional copies between each pair of accessible peers.
        Write tests launch a copy from the target device to the peer using the target's context.
38, device_local_copy:
                Measures bandwidth of cuMemcpyAsync between device buffers local to the GPU.
39, device_local_copy_sm:
                Measures bandwidth of a copy kernel between device buffers local to the GPU.
40, device_local_read_sm:
                Measures bandwidth of a kernel reading from a device buffer local to the GPU.
41, device_local_write_sm:
                Measures bandwidth of a kernel writing to a device buffer local to the GPU.

42, device_to_device_latency_tma:
                Measures latency of a pointer dereference operation between each pair of accessible peers using TMA.
        A 2MB buffer is allocated on a GPU and is accessed by the peer GPU using TMA to determine latency.
        --bufferSize flag is ignored
43, device_local_copy_tma:
                Measures bandwidth of TMA copies between device buffers local to the GPU.

dell@dell:~/nvbandwidth/build$
dell@dell:~/nvbandwidth/build$
dell@dell:~/nvbandwidth/build$
dell@dell:~/nvbandwidth/build$ CUDA_VISIBLE_DEVICE=0,1,2,3,4,5,6 ./nvbandwidth 2>&1 | tee ~/gpu_burn_test/nvbandwidth_full_$(date +%Y%m%d_%H%M).log
nvbandwidth Version: v0.10.0
Built from Git version: v0.10

CUDA Runtime Version: 13.3 (13030)
CUDA Driver Version (API): 13.3 (13030)
Driver Version: 610.57.04

Running host_to_device_memcpy_ce.
memcpy CE CPU(row) -> GPU(column) bandwidth (GB/s)
           0         1         2         3         4         5         6
 0     55.59     55.60     55.60     55.59     55.58     55.60     55.58

SUM host_to_device_memcpy_ce 389.15
COEFFICIENT_OF_VARIATION host_to_device_memcpy_ce 0.00

Running device_to_host_memcpy_ce.
memcpy CE CPU(row) <- GPU(column) bandwidth (GB/s)
           0         1         2         3         4         5         6
 0     57.29     57.30     57.29     57.05     57.00     56.99     56.92

SUM device_to_host_memcpy_ce 399.86
COEFFICIENT_OF_VARIATION device_to_host_memcpy_ce 0.00

Running host_to_device_bidirectional_memcpy_ce.
memcpy CE CPU(row) <-> GPU(column) bandwidth (GB/s)
           0         1         2         3         4         5         6
 0     51.82     51.81     51.87     51.04     51.20     51.09     51.13

SUM host_to_device_bidirectional_memcpy_ce 359.96
COEFFICIENT_OF_VARIATION host_to_device_bidirectional_memcpy_ce 0.00

Running device_to_host_bidirectional_memcpy_ce.
memcpy CE CPU(row) <-> GPU(column) bandwidth (GB/s)
           0         1         2         3         4         5         6
 0     49.09     48.84     49.04     48.54     48.49     48.51     48.09

SUM device_to_host_bidirectional_memcpy_ce 340.60
COEFFICIENT_OF_VARIATION device_to_host_bidirectional_memcpy_ce 0.01

Running device_to_device_memcpy_read_ce.
memcpy CE GPU(row) -> GPU(column) bandwidth (GB/s)
           0         1         2         3         4         5         6
 0       N/A    764.71    765.52    765.18    764.16    765.11    765.11
 1    765.86       N/A    764.98    765.80    765.11    765.73    764.16
 2    766.14    765.32       N/A    765.11    766.07    764.16    765.73
 3    765.80    765.18    765.93       N/A    765.32    765.05    764.50
 4    765.18    764.91    766.07    764.50       N/A    765.05    766.34
 5    765.11    765.18    765.11    765.66    764.37       N/A    764.64
 6    766.07    764.98    765.11    765.80    764.16    766.21       N/A

SUM device_to_device_memcpy_read_ce 32140.19
COEFFICIENT_OF_VARIATION device_to_device_memcpy_read_ce 0.00

Running device_to_device_memcpy_write_ce.
memcpy CE GPU(row) <- GPU(column) bandwidth (GB/s)
           0         1         2         3         4         5         6
 0       N/A    774.50    774.43    774.36    774.22    774.43    774.36
 1    774.57       N/A    774.36    774.43    774.29    774.50    774.36
 2    774.36    774.29       N/A    774.22    774.43    774.43    774.43
 3    774.36    774.15    774.22       N/A    774.29    774.22    774.22
 4    774.29    774.22    774.36    774.36       N/A    774.43    774.43
 5    774.15    774.22    774.15    774.15    774.15       N/A    774.29
 6    774.29    774.29    774.36    774.36    774.50    774.22       N/A

SUM device_to_device_memcpy_write_ce 32521.50
COEFFICIENT_OF_VARIATION device_to_device_memcpy_write_ce 0.00

Running device_to_device_bidirectional_memcpy_read_ce.
memcpy CE GPU(row) <-> GPU(column) Read1 bandwidth (GB/s)
           0         1         2         3         4         5         6
 0       N/A    760.10    761.11    761.11    760.17    760.10    761.18
 1    760.10       N/A    760.31    760.24    760.91    760.24    759.23
 2    761.11    760.31       N/A    760.78    761.18    760.17    761.18
 3    761.11    760.24    760.78       N/A    760.71    760.51    760.44
 4    760.17    760.91    761.18    760.71       N/A    760.78    761.79
 5    760.10    760.24    760.17    760.51    760.78       N/A    760.64
 6    761.18    759.23    761.18    760.44    761.79    760.64       N/A

SUM device_to_device_bidirectional_memcpy_read_ce_read1 31945.78

memcpy CE GPU(row) <-> GPU(column) Read2 bandwidth (GB/s)
           0         1         2         3         4         5         6
 0       N/A    761.11    761.25    760.44    760.51    759.57    760.37
 1    761.11       N/A    760.17    759.63    759.36    759.63    758.63
 2    761.25    760.17       N/A    760.51    760.37    759.57    760.37
 3    760.44    759.63    760.51       N/A    759.77    760.64    760.71
 4    760.51    759.36    760.37    759.77       N/A    759.57    759.36
 5    759.57    759.63    759.57    760.64    759.57       N/A    760.51
 6    760.37    758.63    760.37    760.71    759.36    760.51       N/A

SUM device_to_device_bidirectional_memcpy_read_ce_read2 31924.12

memcpy CE GPU(row) <-> GPU(column) Total bandwidth (GB/s)
           0         1         2         3         4         5         6
 0       N/A   1521.22   1522.36   1521.55   1520.68   1519.67   1521.55
 1   1521.22       N/A   1520.48   1519.87   1520.28   1519.87   1517.86
 2   1522.36   1520.48       N/A   1521.28   1521.55   1519.74   1521.55
 3   1521.55   1519.87   1521.28       N/A   1520.48   1521.15   1521.15
 4   1520.68   1520.28   1521.55   1520.48       N/A   1520.34   1521.15
 5   1519.67   1519.87   1519.74   1521.15   1520.34       N/A   1521.15
 6   1521.55   1517.86   1521.55   1521.15   1521.15   1521.15       N/A

SUM device_to_device_bidirectional_memcpy_read_ce_total 63869.90
COEFFICIENT_OF_VARIATION device_to_device_bidirectional_memcpy_read_ce_total 0.00

Running device_to_device_bidirectional_memcpy_write_ce.
memcpy CE GPU(row) <-> GPU(column) Write1 bandwidth (GB/s)
           0         1         2         3         4         5         6
 0       N/A    770.33    770.33    769.78    769.85    769.91    769.85
 1    770.33       N/A    770.26    769.78    769.91    769.85    769.71
 2    770.33    770.26       N/A    769.98    769.98    769.78    769.85
 3    769.78    769.78    769.98       N/A    769.91    769.71    769.71
 4    769.85    769.91    769.98    769.91       N/A    769.71    769.85
 5    769.91    769.85    769.78    769.71    769.71       N/A    769.91
 6    769.85    769.71    769.85    769.71    769.85    769.91       N/A

SUM device_to_device_bidirectional_memcpy_write_ce_write1 32335.85

memcpy CE GPU(row) <-> GPU(column) Write2 bandwidth (GB/s)
           0         1         2         3         4         5         6
 0       N/A    770.05    770.12    769.91    770.19    769.98    769.98
 1    770.05       N/A    769.98    769.78    769.98    769.98    770.05
 2    770.12    769.98       N/A    770.05    769.91    769.91    769.71
 3    769.91    769.78    770.05       N/A    769.36    769.57    769.57
 4    770.19    769.98    769.91    769.36       N/A    769.64    769.71
 5    769.98    769.98    769.91    769.57    769.64       N/A    769.50
 6    769.98    770.05    769.71    769.57    769.71    769.50       N/A

SUM device_to_device_bidirectional_memcpy_write_ce_write2 32333.92

memcpy CE GPU(row) <-> GPU(column) Total bandwidth (GB/s)
           0         1         2         3         4         5         6
 0       N/A   1540.38   1540.45   1539.69   1540.04   1539.90   1539.83
 1   1540.38       N/A   1540.24   1539.55   1539.90   1539.83   1539.76
 2   1540.45   1540.24       N/A   1540.04   1539.90   1539.69   1539.55
 3   1539.69   1539.55   1540.04       N/A   1539.28   1539.28   1539.28
 4   1540.04   1539.90   1539.90   1539.28       N/A   1539.35   1539.55
 5   1539.90   1539.83   1539.69   1539.28   1539.35       N/A   1539.41
 6   1539.83   1539.76   1539.55   1539.28   1539.55   1539.41       N/A

SUM device_to_device_bidirectional_memcpy_write_ce_total 64669.78
```

### 2.5 LARGE METRIX 
- **목적:**  동일한 대형 행렬연산을 개별로 실행시켜, GPU별 처리 성능이 서로 얼마나 균일한지 검증. 같은 모델의 GPU라도 실리콘 개별편차(binning), 클럭 거동 차이로 성능이 조금씩 다를 수 있는데, 최고/최저 편차가 3% 이내면 정상, 그 이상이면 특정 GPU에 잠재적 하드웨어 이슈가 있다고 의심할 근거가 됨

**outpu**
```bash
dell@dell:~/gpu_burn$ mkdir -p ~/gpu_burn_test/large_matrix
dell@dell:~/gpu_burn$
dell@dell:~/gpu_burn$
dell@dell:~/gpu_burn$ cd ..
dell@dell:~$ cd gpu_burn_test/large_matrix/
dell@dell:~/gpu_burn_test/large_matrix$
dell@dell:~/gpu_burn_test/large_matrix$
dell@dell:~/gpu_burn_test/large_matrix$
dell@dell:~/gpu_burn_test/large_matrix$
dell@dell:~/gpu_burn_test/large_matrix$ for i in 0 1 2 3 4 5 6; do
>   CUDA_VISIBLE_DEVICES=$i ~/gpu_burn/gpu_burn -d 300 > gpu_${i}.log 2>&1  &
> done
[1] 490552
[2] 490553
[3] 490554
[4] 490555
[5] 490556
[6] 490557
[7] 490558
dell@dell:~/gpu_burn_test/large_matrix$ ls
gpu_0.log  gpu_1.log  gpu_2.log  gpu_3.log  gpu_4.log  gpu_5.log  gpu_6.log
[1]   Exit 123                CUDA_VISIBLE_DEVICES=$i ~/gpu_burn/gpu_burn -d 300 > gpu_${i}.log 2>&1
[2]   Exit 123                CUDA_VISIBLE_DEVICES=$i ~/gpu_burn/gpu_burn -d 300 > gpu_${i}.log 2>&1
[3]   Exit 123                CUDA_VISIBLE_DEVICES=$i ~/gpu_burn/gpu_burn -d 300 > gpu_${i}.log 2>&1
[4]   Exit 123                CUDA_VISIBLE_DEVICES=$i ~/gpu_burn/gpu_burn -d 300 > gpu_${i}.log 2>&1
[5]   Exit 123                CUDA_VISIBLE_DEVICES=$i ~/gpu_burn/gpu_burn -d 300 > gpu_${i}.log 2>&1
[6]-  Exit 123                CUDA_VISIBLE_DEVICES=$i ~/gpu_burn/gpu_burn -d 300 > gpu_${i}.log 2>&1
[7]+  Exit 123                CUDA_VISIBLE_DEVICES=$i ~/gpu_burn/gpu_burn -d 300 > gpu_${i}.log 2>&1
dell@dell:~/gpu_burn_test/large_matrix$
```

**watch**
```bash
Every 5.0s: nvidia-smi --query-gpu=index,utilization.gpu,temperature.gpu,power.draw --format=csv                                               dell: Mon Aug 31 01:28:09 2026

index, utilization.gpu [%], temperature.gpu, power.draw [W]
0, 0 %, 28, 182.89 W
1, 0 %, 40, 185.25 W
2, 0 %, 37, 185.23 W
3, 0 %, 30, 180.84 W
4, 0 %, 42, 186.16 W
5, 0 %, 30, 183.25 W
6, 0 %, 39, 184.35 W
```
