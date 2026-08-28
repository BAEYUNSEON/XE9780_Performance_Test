# XE9780_Performance_Test

# Power Edge XE9780 Server Performance Test 



- **Connected build host:** `root@192.168.50.22` — Ubuntu 24.04.4 LTS, x86_64, 48 vCPU, 62 GB RAM, 326 GB free
- **Air-gapped target:** Ubuntu 24.04 Server (single node, no DNS, no NTP) — *pending*
- **Driven from:** Windows 11 workstation over SSH
- **Log started:** 2026-06-19

> Note: extremely long `curl`/`wget` progress meters are trimmed to their meaningful lines for
> readability; all command-level output is otherwise recorded verbatim.

---

## Phase 1 — 최초 구축 (8/27일 이미 설치 하였고 확인 CMD)

### 1.1 OS 설치 
- **설치 OS :** Ubuntu 24.04.4 LTS

**Output**
```
dell@dell:~$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 24.04.4 LTS
Release:        24.04
Codename:       noble
```
- **커벌 버전 :** 6.8.0-138-generic
```
dell@dell:~$ uname -r
6.8.0-138-generic
```

### 1.2 GPU 드라이버 & CUDA
- **NVIDIA 드라이버 버전 & GPU 인식 상태**
```bash
dell@dell:~$ nvidia-smi
Fri Aug 28 00:33:07 2026
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 610.57.04              KMD Version: 610.57.04     CUDA UMD Version: 13.3     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA B300 SXM6 AC            On  |   00000000:1A:00.0 Off |                    0 |
| N/A   28C    P0            181W / 1100W |       0MiB / 275040MiB |      0%      Default |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA B300 SXM6 AC            On  |   00000000:69:00.0 Off |                    0 |
| N/A   40C    P0            184W / 1100W |       0MiB / 275040MiB |      0%      Default |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   2  NVIDIA B300 SXM6 AC            On  |   00000000:DB:00.0 Off |                    0 |
| N/A   37C    P0            183W / 1100W |       0MiB / 275040MiB |      0%      Default |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   3  NVIDIA B300 SXM6 AC            On  |   00000001:1A:00.0 Off |                    0 |
| N/A   29C    P0            179W / 1100W |       0MiB / 275040MiB |      0%      Default |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   4  NVIDIA B300 SXM6 AC            On  |   00000001:69:00.0 Off |                    0 |
| N/A   42C    P0            184W / 1100W |       0MiB / 275040MiB |      0%      Default |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   5  NVIDIA B300 SXM6 AC            On  |   00000001:B5:00.0 Off |                    0 |
| N/A   29C    P0            181W / 1100W |       0MiB / 275040MiB |      0%      Default |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   6  NVIDIA B300 SXM6 AC            On  |   00000001:DB:00.0 Off |                    0 |
| N/A   38C    P0            182W / 1100W |       0MiB / 275040MiB |      0%      Default |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|  No running processes found                                                             |
+-----------------------------------------------------------------------------------------+
```

- **드라이버 패키지 상세(Open Kernel Module 여부 확인**
```bash
dell@dell:~$ modinfo nvidia | grep -E "version|filename"
filename:       /lib/modules/6.8.0-138-generic/updates/dkms/nvidia.ko.zst
version:        610.57.04
srcversion:     5B7E5876650E7011D207A04
vermagic:       6.8.0-138-generic SMP preempt mod_unload modversions
```

```bash
dell@dell:~$ nvidia-smi --query-gpu=driver_version,name,compute_cap --format=csv
driver_version, name, compute_cap
610.57.04, NVIDIA B300 SXM6 AC, 10.3
610.57.04, NVIDIA B300 SXM6 AC, 10.3
610.57.04, NVIDIA B300 SXM6 AC, 10.3
610.57.04, NVIDIA B300 SXM6 AC, 10.3
610.57.04, NVIDIA B300 SXM6 AC, 10.3
610.57.04, NVIDIA B300 SXM6 AC, 10.3
610.57.04, NVIDIA B300 SXM6 AC, 10.3
```
- **CUDA Toolkit 버전**
```bash
dell@dell:~$ nvcc --version
Command 'nvcc' not found, but can be installed with:
sudo apt install nvidia-cuda-toolkit
dell@dell:~$ cat /usr/local/cuda/version.json
{
   "cuda" : {
      "name" : "CUDA SDK",
      "version" : "13.3.1"
   },
   "cuda_crt" : {
      "name" : "CUDA crt Compiler for CUDA applications",
      "version" : "13.3.73"
   },
   "cuda_ctadvisor" : {
      "name" : "CUDA Compile Time Advisor",
      "version" : "13.3.33"
   },
   "cuda_cudart" : {
      "name" : "CUDA Runtime (cudart)",
      "version" : "13.3.29"
   },
   "cuda_culibos" : {
      "name" : "CUDA DEV culibos is a Math Libraries",
      "version" : "13.3.33"
   },
   "cuda_cuobjdump" : {
      "name" : "cuobjdump",
      "version" : "13.3.73"
   },
   "cuda_cupti" : {
      "name" : "CUPTI",
      "version" : "13.3.75"
   },
   "cuda_cuxxfilt" : {
      "name" : "CUDA cu++ filt",
      "version" : "13.3.29"
   },
   "cuda_gdb" : {
      "name" : "CUDA GDB",
      "version" : "13.3.73"
   },
   "cuda_nvcc" : {
      "name" : "CUDA NVCC",
      "version" : "13.3.73"
   },
   "cuda_nvdisasm" : {
      "name" : "CUDA nvdisasm",
      "version" : "13.3.73"
   },
   "cuda_nvml_dev" : {
      "name" : "CUDA NVML Headers",
      "version" : "13.3.29"
   },
   "cuda_nvprune" : {
      "name" : "CUDA nvprune",
      "version" : "13.3.29"
   },
   "cuda_nvrtc" : {
      "name" : "CUDA NVRTC",
      "version" : "13.3.33"
   },
   "cuda_nvtx" : {
      "name" : "CUDA NVTX",
      "version" : "13.3.29"
   },
   "cuda_opencl" : {
      "name" : "CUDA OpenCL",
      "version" : "13.3.27"
   },
   "cuda_profiler_api" : {
      "name" : "CUDA Profiler API",
      "version" : "13.3.27"
   },
   "cuda_sandbox_dev" : {
      "name" : "NVIDIA Sandbox Utils",
      "version" : "13.3.29"
   },
   "cuda_sanitizer_api" : {
      "name" : "CUDA Compute Sanitizer API",
      "version" : "13.3.75"
   },
   "libcublas" : {
      "name" : "CUDA cuBLAS",
      "version" : "13.6.0.2"
   },
   "libcufft" : {
      "name" : "CUDA cuFFT",
      "version" : "12.3.0.29"
   },
   "libcufile" : {
      "name" : "GPUDirect Storage (cufile)",
      "version" : "1.18.1.6"
   },
   "libcurand" : {
      "name" : "CUDA cuRAND",
      "version" : "10.4.3.29"
   },
   "libcusolver" : {
      "name" : "CUDA cuSOLVER",
      "version" : "12.2.6.9"
   },
   "libcusparse" : {
      "name" : "CUDA cuSPARSE",
      "version" : "12.8.2.51"
   },
   "libnpp" : {
      "name" : "CUDA NPP",
      "version" : "13.1.2.81"
   },
   "libnvfatbin" : {
      "name" : "Fatbin interaction library",
      "version" : "13.3.29"
   },
   "libnvjitlink" : {
      "name" : "JIT Linker Library",
      "version" : "13.3.33"
   },
   "libnvjpeg" : {
      "name" : "CUDA nvJPEG",
      "version" : "13.2.1.68"
   },
   "libnvptxcompiler" : {
      "name" : "CUDA PTX compiler",
      "version" : "13.3.73"
   },
   "libnvvm" : {
      "name" : "NVVM",
      "version" : "13.3.73"
   },
   "nsight_compute" : {
      "name" : "Nsight Compute",
      "version" : "2026.2.1.5"
   },
   "nsight_systems" : {
      "name" : "Nsight Systems",
      "version" : "2026.1.3.425"
   },
   "nvidia_driver" : {
      "name" : "NVIDIA Linux Driver",
      "version" : "610.43.02"
   },
   "nvidia_fs" : {
      "name" : "NVIDIA file-system",
      "version" : "2.29.4"
   }
}
```
- **cuDNN 버전-없음, python3 torch 버전도없음**
```bash

```

### 1.3 NVLink/Fabric & 네트워크
- **NVIDIA Fabric Manager 버전 및 서비스상태**
**Output**
```
dell@dell:~$ nv-fabricmanager --version
Fabric Manager version is : 610.57.04
Build Info - Branch: rel/gpu_drv/r610/r610_85-4, Changelist: 0dell@dell:~$
```

```bash
dell@dell:~$ systemctl status nvidia-fabricmanager
● nvidia-fabricmanager.service - NVIDIA fabric manager service
     Loaded: loaded (/usr/lib/systemd/system/nvidia-fabricmanager.service; enabled; preset: enabled)
     Active: active (running) since Thu 2026-08-27 07:13:21 UTC; 17h ago
   Main PID: 31082 (nv-fabricmanage)
      Tasks: 90 (limit: 629145)
     Memory: 39.8M (peak: 49.0M)
        CPU: 4min 49.977s
     CGroup: /system.slice/nvidia-fabricmanager.service
             ├─31060 /opt/nvidia/nvlsm/sbin/nvlsm -F /usr/share/nvidia/nvlsm/nvlsm.conf -B --pid_file /var/run/nvidia-fabricmanager/nvlsm.pid -g 0x7425540300353de9
             ├─31062 osm_crashd
             └─31082 /usr/bin/nv-fabricmanager -c /usr/share/nvidia/nvswitch/fabricmanager.cfg -g 0x7425540300353de9

Aug 27 07:13:16 dell OpenSM[31056]: -I- Set parameter "plugin_options" to "-grpc_mgr --config_file /usr/share/nvidia/nvlsm/grpc_mgr.conf" by configuration file
Aug 27 07:13:16 dell OpenSM[31056]: -I- Configuration loaded
Aug 27 07:13:16 dell OpenSM[31060]: /var/log/nvlsm.log log file opened
Aug 27 07:13:16 dell OpenSM[31060]: OpenSM 2025.10.14_42349a2_821fcee_ae214d2
Aug 27 07:13:16 dell OpenSM[31060]: Entering DISCOVERING state
Aug 27 07:13:17 dell OpenSM[31060]: Entering MASTER state
Aug 27 07:13:21 dell nv-fabricmanager[31082]: NodeId 0 partition id 57082 is activated.
Aug 27 07:13:21 dell nv-fabricmanager[31082]: Successfully configured all the available GPUs and NVSwitches to route NVLink traffic. NVLink Peer-to-Peer support will be enabled once the GP>
Aug 27 07:13:21 dell nvidia-fabricmanager-start.sh[30946]: Started "Nvidia Fabric Manager"
Aug 27 07:13:21 dell systemd[1]: Started nvidia-fabricmanager.service - NVIDIA fabric manager service.
lines 1-22/22 (END)
```
- **NVLink/NVSwitch 토폴로지 확인**
**Output**
```bash
dell@dell:~$ nvidia-smi topo -m
        GPU0    GPU1    GPU2    GPU3    GPU4    GPU5    GPU6    CPU Affinity    NUMA Affinity   GPU NUMA ID
GPU0     X      NV18    NV18    NV18    NV18    NV18    NV18    0,2,4,6,8,10    0               N/A
GPU1    NV18     X      NV18    NV18    NV18    NV18    NV18    0,2,4,6,8,10    0               N/A
GPU2    NV18    NV18     X      NV18    NV18    NV18    NV18    0,2,4,6,8,10    0               N/A
GPU3    NV18    NV18    NV18     X      NV18    NV18    NV18    1,3,5,7,9,11    1               N/A
GPU4    NV18    NV18    NV18    NV18     X      NV18    NV18    1,3,5,7,9,11    1               N/A
GPU5    NV18    NV18    NV18    NV18    NV18     X      NV18    1,3,5,7,9,11    1               N/A
GPU6    NV18    NV18    NV18    NV18    NV18    NV18     X      1,3,5,7,9,11    1               N/A

Legend:

  X    = Self
  SYS  = Connection traversing PCIe as well as the SMP interconnect between NUMA nodes (e.g., QPI/UPI)
  NODE = Connection traversing PCIe as well as the interconnect between PCIe Host Bridges within a NUMA node
  PHB  = Connection traversing PCIe as well as a PCIe Host Bridge (typically the CPU)
  PXB  = Connection traversing multiple PCIe bridges (without traversing the PCIe Host Bridge)
  PIX  = Connection traversing at most a single PCIe bridge
  NV#  = Connection traversing a bonded set of # NVLinks
```

```bash
dell@dell:~$ nvidia-smi nvlink --status
GPU 0: NVIDIA B300 SXM6 AC (UUID: GPU-bce5282f-d716-d136-5759-b7181a7a55df)
         Link 0: 53.125 GB/s
         Link 1: 53.125 GB/s
         Link 2: 53.125 GB/s
         Link 3: 53.125 GB/s
         Link 4: 53.125 GB/s
         Link 5: 53.125 GB/s
         Link 6: 53.125 GB/s
         Link 7: 53.125 GB/s
         Link 8: 53.125 GB/s
         Link 9: 53.125 GB/s
         Link 10: 53.125 GB/s
         Link 11: 53.125 GB/s
         Link 12: 53.125 GB/s
         Link 13: 53.125 GB/s
         Link 14: 53.125 GB/s
         Link 15: 53.125 GB/s
         Link 16: 53.125 GB/s
         Link 17: 53.125 GB/s
GPU 1: NVIDIA B300 SXM6 AC (UUID: GPU-d6fcaafa-e017-734b-43a5-9f5953cf7150)
         Link 0: 53.125 GB/s
         Link 1: 53.125 GB/s
         Link 2: 53.125 GB/s
         Link 3: 53.125 GB/s
         Link 4: 53.125 GB/s
         Link 5: 53.125 GB/s
         Link 6: 53.125 GB/s
         Link 7: 53.125 GB/s
         Link 8: 53.125 GB/s
         Link 9: 53.125 GB/s
         Link 10: 53.125 GB/s
         Link 11: 53.125 GB/s
         Link 12: 53.125 GB/s
         Link 13: 53.125 GB/s
         Link 14: 53.125 GB/s
         Link 15: 53.125 GB/s
         Link 16: 53.125 GB/s
         Link 17: 53.125 GB/s
GPU 2: NVIDIA B300 SXM6 AC (UUID: GPU-63702342-9bed-efb1-1262-10971a1218cd)
         Link 0: 53.125 GB/s
         Link 1: 53.125 GB/s
         Link 2: 53.125 GB/s
         Link 3: 53.125 GB/s
         Link 4: 53.125 GB/s
         Link 5: 53.125 GB/s
         Link 6: 53.125 GB/s
         Link 7: 53.125 GB/s
         Link 8: 53.125 GB/s
         Link 9: 53.125 GB/s
         Link 10: 53.125 GB/s
         Link 11: 53.125 GB/s
         Link 12: 53.125 GB/s
         Link 13: 53.125 GB/s
         Link 14: 53.125 GB/s
         Link 15: 53.125 GB/s
         Link 16: 53.125 GB/s
         Link 17: 53.125 GB/s
GPU 3: NVIDIA B300 SXM6 AC (UUID: GPU-50db20c5-bd33-c81d-2eea-d6f6b623c0f4)
         Link 0: 53.125 GB/s
         Link 1: 53.125 GB/s
         Link 2: 53.125 GB/s
         Link 3: 53.125 GB/s
         Link 4: 53.125 GB/s
         Link 5: 53.125 GB/s
         Link 6: 53.125 GB/s
         Link 7: 53.125 GB/s
         Link 8: 53.125 GB/s
         Link 9: 53.125 GB/s
         Link 10: 53.125 GB/s
         Link 11: 53.125 GB/s
         Link 12: 53.125 GB/s
         Link 13: 53.125 GB/s
         Link 14: 53.125 GB/s
         Link 15: 53.125 GB/s
         Link 16: 53.125 GB/s
         Link 17: 53.125 GB/s
GPU 4: NVIDIA B300 SXM6 AC (UUID: GPU-fa889c02-065e-66b6-15a8-e052e6fe3743)
         Link 0: 53.125 GB/s
         Link 1: 53.125 GB/s
         Link 2: 53.125 GB/s
         Link 3: 53.125 GB/s
         Link 4: 53.125 GB/s
         Link 5: 53.125 GB/s
         Link 6: 53.125 GB/s
         Link 7: 53.125 GB/s
         Link 8: 53.125 GB/s
         Link 9: 53.125 GB/s
         Link 10: 53.125 GB/s
         Link 11: 53.125 GB/s
         Link 12: 53.125 GB/s
         Link 13: 53.125 GB/s
         Link 14: 53.125 GB/s
         Link 15: 53.125 GB/s
         Link 16: 53.125 GB/s
         Link 17: 53.125 GB/s
GPU 5: NVIDIA B300 SXM6 AC (UUID: GPU-1ba19bc3-3adc-acaf-5b88-5c623b05a799)
         Link 0: 53.125 GB/s
         Link 1: 53.125 GB/s
         Link 2: 53.125 GB/s
         Link 3: 53.125 GB/s
         Link 4: 53.125 GB/s
         Link 5: 53.125 GB/s
         Link 6: 53.125 GB/s
         Link 7: 53.125 GB/s
         Link 8: 53.125 GB/s
         Link 9: 53.125 GB/s
         Link 10: 53.125 GB/s
         Link 11: 53.125 GB/s
         Link 12: 53.125 GB/s
         Link 13: 53.125 GB/s
         Link 14: 53.125 GB/s
         Link 15: 53.125 GB/s
         Link 16: 53.125 GB/s
         Link 17: 53.125 GB/s
GPU 6: NVIDIA B300 SXM6 AC (UUID: GPU-07634869-498e-829a-ecb5-9f1611c125fb)
         Link 0: 53.125 GB/s
         Link 1: 53.125 GB/s
         Link 2: 53.125 GB/s
         Link 3: 53.125 GB/s
         Link 4: 53.125 GB/s
         Link 5: 53.125 GB/s
         Link 6: 53.125 GB/s
         Link 7: 53.125 GB/s
         Link 8: 53.125 GB/s
         Link 9: 53.125 GB/s
         Link 10: 53.125 GB/s
         Link 11: 53.125 GB/s
         Link 12: 53.125 GB/s
         Link 13: 53.125 GB/s
         Link 14: 53.125 GB/s
         Link 15: 53.125 GB/s
         Link 16: 53.125 GB/s
         Link 17: 53.125 GB/s

```
- **MLNX_OFED(DOCA-OPED)버전 - 없음**



- **InfiniBand 링크/펌웨어 상태**
```bash
dell@dell:~$ ibstat
CA 'mlx5_0'
        CA type: MT4131
        Number of ports: 1
        Firmware version: 40.46.5500
        Hardware version: 0
        Node GUID: 0x7425540300353ded
        System image GUID: 0x7425540300353ded
        Port 1:
                State: Down
                Physical state: Disabled
                Rate: 10
                Base lid: 65535
                LMC: 0
                SM lid: 0
                Capability mask: 0xa750e848
                Port GUID: 0x7425540300353ded
                Link layer: InfiniBand
CA 'mlx5_1'
        CA type: MT4131
        Number of ports: 1
        Firmware version: 40.46.5500
        Hardware version: 0
        Node GUID: 0x7425540300353e0d
        System image GUID: 0x7425540300353e0d
        Port 1:
                State: Down
                Physical state: Disabled
                Rate: 10
                Base lid: 65535
                LMC: 0
                SM lid: 0
                Capability mask: 0xa750e848
                Port GUID: 0x7425540300353e0d
                Link layer: InfiniBand
CA 'mlx5_10'
        CA type: MT4131
        Number of ports: 1
        Firmware version: 40.46.5500
        Hardware version: 0
        Node GUID: 0x7425540300353e4d
        System image GUID: 0x7425540300353e4d
        Port 1:
                State: Down
                Physical state: Disabled
                Rate: 10
                Base lid: 65535
                LMC: 0
                SM lid: 0
                Capability mask: 0xa750e848
                Port GUID: 0x7425540300353e4d
                Link layer: InfiniBand
CA 'mlx5_2'
        CA type: MT4129
        Number of ports: 1
        Firmware version: 28.47.2526
        Hardware version: 0
        Node GUID: 0x7425540300353de9
        System image GUID: 0x7425540300353de9
        Port 1:
                State: Active
                Physical state: LinkUp
                Rate: 100
                Base lid: 1
                LMC: 0
                SM lid: 1
                Capability mask: 0xa750e84a
                Port GUID: 0x7425540300353de9
                Link layer: InfiniBand
CA 'mlx5_3'
        CA type: MT4129
        Number of ports: 1
        Firmware version: 28.47.2526
        Hardware version: 0
        Node GUID: 0x7425540300353dea
        System image GUID: 0x7425540300353de9
        Port 1:
                State: Active
                Physical state: LinkUp
                Rate: 100
                Base lid: 4
                LMC: 0
                SM lid: 1
                Capability mask: 0xa750e848
                Port GUID: 0x7425540300353dea
                Link layer: InfiniBand
CA 'mlx5_4'
        CA type: MT4129
        Number of ports: 1
        Firmware version: 28.47.2526
        Hardware version: 0
        Node GUID: 0x7425540300353deb
        System image GUID: 0x7425540300353de9
        Port 1:
                State: Active
                Physical state: LinkUp
                Rate: 100
                Base lid: 5
                LMC: 0
                SM lid: 1
                Capability mask: 0xa740ec48
                Port GUID: 0x7425540300353deb
                Link layer: InfiniBand
CA 'mlx5_5'
        CA type: MT4129
        Number of ports: 1
        Firmware version: 28.47.2526
        Hardware version: 0
        Node GUID: 0x7425540300353dec
        System image GUID: 0x7425540300353de9
        Port 1:
                State: Active
                Physical state: LinkUp
                Rate: 100
                Base lid: 6
                LMC: 0
                SM lid: 1
                Capability mask: 0xa740ec48
                Port GUID: 0x7425540300353dec
                Link layer: InfiniBand
CA 'mlx5_6'
        CA type: MT4131
        Number of ports: 1
        Firmware version: 40.46.5500
        Hardware version: 0
        Node GUID: 0x7425540300353dfd
        System image GUID: 0x7425540300353dfd
        Port 1:
                State: Down
                Physical state: Disabled
                Rate: 10
                Base lid: 65535
                LMC: 0
                SM lid: 0
                Capability mask: 0xa750e848
                Port GUID: 0x7425540300353dfd
                Link layer: InfiniBand
CA 'mlx5_7'
        CA type: MT4131
        Number of ports: 1
        Firmware version: 40.46.5500
        Hardware version: 0
        Node GUID: 0x7425540300353e5d
        System image GUID: 0x7425540300353e5d
        Port 1:
                State: Down
                Physical state: Disabled
                Rate: 10
                Base lid: 65535
                LMC: 0
                SM lid: 0
                Capability mask: 0xa750e848
                Port GUID: 0x7425540300353e5d
                Link layer: InfiniBand
CA 'mlx5_8'
        CA type: MT4131
        Number of ports: 1
        Firmware version: 40.46.5500
        Hardware version: 0
        Node GUID: 0x7425540300353e3d
        System image GUID: 0x7425540300353e3d
        Port 1:
                State: Down
                Physical state: Disabled
                Rate: 10
                Base lid: 65535
                LMC: 0
                SM lid: 0
                Capability mask: 0xa750e848
                Port GUID: 0x7425540300353e3d
                Link layer: InfiniBand
CA 'mlx5_9'
        CA type: MT4131
        Number of ports: 1
        Firmware version: 40.46.5500
        Hardware version: 0
        Node GUID: 0x7425540300353e2d
        System image GUID: 0x7425540300353e2d
        Port 1:
                State: Down
                Physical state: Disabled
                Rate: 10
                Base lid: 65535
                LMC: 0
                SM lid: 0
                Capability mask: 0xa750e848
                Port GUID: 0x7425540300353e2d
                Link layer: InfiniBand
```

```bash
dell@dell:~$ ibv_devinfo
Command 'ibv_devinfo' not found, but can be installed with:
sudo apt install ibverbs-utils
dell@dell:~$ mlxfwmanager
mlxfwmanager: command not found
```
### 1.4 컨테이너/오케스트레이션
- **NVIDIA Container Toolkit 버전**
```bash
dell@dell:~$ nvidia-ctk --version
NVIDIA Container Toolkit CLI version 1.20.0
commit: 5505e2f94d9aaa08561490db974ba3cd676af209

dell@dell:~$ dpkg -l | grep nvidia-container-toolkit
ii  nvidia-container-toolkit              1.20.0-1                                amd64        NVIDIA Container toolkit
ii  nvidia-container-toolkit-base         1.20.0-1                                amd64        NVIDIA Container Toolkit Base
```

- **Docker + GPU런타임 버전**
```bash
dell@dell:~$ docker --version
Docker version 29.7.2, build a7dcaa6
dell@dell:~$ docker info | grep -o runtime
dell@dell:~$ docker info | grep -i runtime
 Runtimes: io.containerd.runc.v2 nvidia runc
 Default Runtime: runc
```
- **DCGM  버전 및 진단**
**Command**
```bash
dell@dell:~$ sudo apt install -y datacenter-gpu-manager
[sudo] password for dell:
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following packages were automatically installed and are no longer required:
  bridge-utils dns-root-data dnsmasq-base ubuntu-fan
Use 'sudo apt autoremove' to remove them.
The following NEW packages will be installed:
  datacenter-gpu-manager
0 upgraded, 1 newly installed, 0 to remove and 58 not upgraded.
Need to get 911 MB of archives.
After this operation, 1,827 MB of additional disk space will be used.
Get:1 https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64  datacenter-gpu-manager 1:3.3.9 [911 MB]
Fetched 911 MB in 1min 16s (12.0 MB/s)
Selecting previously unselected package datacenter-gpu-manager.
(Reading database ... 125065 files and directories currently installed.)
Preparing to unpack .../datacenter-gpu-manager_1%3a3.3.9_amd64.deb ...
Unpacking datacenter-gpu-manager (1:3.3.9) ...
Setting up datacenter-gpu-manager (1:3.3.9) ...
Scanning processes...
Scanning processor microcode...
Scanning linux images...

Running kernel seems to be up-to-date.

The processor microcode seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
```

```bash
dell@dell:~$ dcgmi --version
dcgmi  version: 3.3.9


dell@dell:~$ dcgmi discovery -l # 반응이 없음
dell@dell:~$ sudo systemctl status nvidia-dcgm
○ nvidia-dcgm.service - NVIDIA DCGM service
     Loaded: loaded (/usr/lib/systemd/system/nvidia-dcgm.service; enabled; preset: enabled)
     Active: inactive (dead)
dell@dell:~$ sudo systemctl restart nvidia-dcgm
dell@dell:~$
dell@dell:~$
dell@dell:~$
dell@dell:~$ sudo systemctl status nvidia-dcgm
● nvidia-dcgm.service - NVIDIA DCGM service
     Loaded: loaded (/usr/lib/systemd/system/nvidia-dcgm.service; enabled; preset: enabled)
     Active: active (running) since Fri 2026-08-28 01:36:35 UTC; 14s ago
   Main PID: 100107 (nv-hostengine)
      Tasks: 9 (limit: 629145)
     Memory: 22.6M (peak: 23.0M)
        CPU: 180ms
     CGroup: /system.slice/nvidia-dcgm.service
             └─100107 /usr/bin/nv-hostengine -n --service-account nvidia-dcgm

Aug 28 01:36:35 dell systemd[1]: Started nvidia-dcgm.service - NVIDIA DCGM service.
Aug 28 01:36:35 dell nv-hostengine[100107]: DCGM initialized
Aug 28 01:36:35 dell nv-hostengine[100107]: Started host engine version 3.3.9 using port number: 5555

dell@dell:~$ dcgmi discovery -l
7 GPUs found.
+--------+----------------------------------------------------------------------+
| GPU ID | Device Information                                                   |
+--------+----------------------------------------------------------------------+
| 0      | Name: NVIDIA B300 SXM6 AC                                            |
|        | PCI Bus ID: 00000000:1A:00.0                                         |
|        | Device UUID: GPU-bce5282f-d716-d136-5759-b7181a7a55df                |
+--------+----------------------------------------------------------------------+
| 1      | Name: NVIDIA B300 SXM6 AC                                            |
|        | PCI Bus ID: 00000000:69:00.0                                         |
|        | Device UUID: GPU-d6fcaafa-e017-734b-43a5-9f5953cf7150                |
+--------+----------------------------------------------------------------------+
| 2      | Name: NVIDIA B300 SXM6 AC                                            |
|        | PCI Bus ID: 00000000:DB:00.0                                         |
|        | Device UUID: GPU-63702342-9bed-efb1-1262-10971a1218cd                |
+--------+----------------------------------------------------------------------+
| 3      | Name: NVIDIA B300 SXM6 AC                                            |
|        | PCI Bus ID: 00000001:1A:00.0                                         |
|        | Device UUID: GPU-50db20c5-bd33-c81d-2eea-d6f6b623c0f4                |
+--------+----------------------------------------------------------------------+
| 4      | Name: NVIDIA B300 SXM6 AC                                            |
|        | PCI Bus ID: 00000001:69:00.0                                         |
|        | Device UUID: GPU-fa889c02-065e-66b6-15a8-e052e6fe3743                |
+--------+----------------------------------------------------------------------+
| 5      | Name: NVIDIA B300 SXM6 AC                                            |
|        | PCI Bus ID: 00000001:B5:00.0                                         |
|        | Device UUID: GPU-1ba19bc3-3adc-acaf-5b88-5c623b05a799                |
+--------+----------------------------------------------------------------------+
| 6      | Name: NVIDIA B300 SXM6 AC                                            |
|        | PCI Bus ID: 00000001:DB:00.0                                         |
|        | Device UUID: GPU-07634869-498e-829a-ecb5-9f1611c125fb                |
+--------+----------------------------------------------------------------------+
0 NvSwitches found.
+-----------+
| Switch ID |
+-----------+
+-----------+
0 CPUs found.
+--------+----------------------------------------------------------------------+
| CPU ID | Device Information                                                   |
+--------+----------------------------------------------------------------------+
+--------+----------------------------------------------------------------------+

```

- **Enroot / Pyxus (Slurm 사용시)**
```bash
dell@dell:~$ enroot version
4.2.1
dell@dell:~$ srun --version
slurm-wlm 23.11.4

```


## Phase 2 — Performance Test (8/28)

### 1.1 DCGM 진단 (하드웨어 기본 상태 확인)
- **벤치마그 전에 GPU 자체에 결함(ECC에러, 온도, 전력, PCIe재훈련 등)이 없는지 먼저 걸러내는 단계**
```bash

```
