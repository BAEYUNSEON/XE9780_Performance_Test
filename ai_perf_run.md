# 3.AI Perf Test 
### 3. phase - AI Perf 최종 서비스 모델 검증

## 3-0. 사전 점검
```bash
dell@dell:~$ nvidia-smi
Mon Aug 31 04:56:42 2026
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 610.57.04              KMD Version: 610.57.04     CUDA UMD Version: 13.3     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA B300 SXM6 AC            On  |   00000000:1A:00.0 Off |                    0 |
| N/A   49C    P0            844W / 1100W |  246718MiB / 275040MiB |    100%      Default |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   1  NVIDIA B300 SXM6 AC            On  |   00000000:69:00.0 Off |                    0 |
| N/A   64C    P0            875W / 1100W |  246718MiB / 275040MiB |    100%      Default |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   2  NVIDIA B300 SXM6 AC            On  |   00000000:DB:00.0 Off |                    0 |
| N/A   54C    P0            864W / 1100W |  135555MiB / 275040MiB |    100%      Default |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   3  NVIDIA B300 SXM6 AC            On  |   00000001:1A:00.0 Off |                    0 |
| N/A   52C    P0            851W / 1100W |  135619MiB / 275040MiB |    100%      Default |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   4  NVIDIA B300 SXM6 AC            On  |   00000001:69:00.0 Off |                    0 |
| N/A   67C    P0            882W / 1100W |  246718MiB / 275040MiB |    100%      Default |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   5  NVIDIA B300 SXM6 AC            On  |   00000001:B5:00.0 Off |                    0 |
| N/A   49C    P0            847W / 1100W |  246718MiB / 275040MiB |    100%      Default |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+
|   6  NVIDIA B300 SXM6 AC            On  |   00000001:DB:00.0 Off |                    0 |
| N/A   63C    P0            873W / 1100W |  246718MiB / 275040MiB |    100%      Default |
|                                         |                        |             Disabled |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A          559352      C   ./gpu_burn                            24670... |
|    1   N/A  N/A          559355      C   ./gpu_burn                            24670... |
|    2   N/A  N/A          559357      C   ./gpu_burn                            13483... |
|    2   N/A  N/A          564457      C   /usr/bin/python                         684MiB |
|    3   N/A  N/A          559359      C   ./gpu_burn                            13559... |
|    4   N/A  N/A          559361      C   ./gpu_burn                            24670... |
|    5   N/A  N/A          559363      C   ./gpu_burn                            24670... |
|    6   N/A  N/A          559365      C   ./gpu_burn                            24670... |
+-----------------------------------------------------------------------------------------+
dell@dell:~$ nvidia-ctk --version
NVIDIA Container Toolkit CLI version 1.20.0
commit: 5505e2f94d9aaa08561490db974ba3cd676af209
dell@dell:~$ docker info | grep -i runtime
 Runtimes: io.containerd.runc.v2 nvidia runc
 Default Runtime: nvidia
```

## 3-1. 단일 노드 K8s 설치 (kubeadm)
### 1-A. kubeadm 방식
```bash
dell@dell:~$ cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
[sudo] password for dell:
overlay
br_netfilter


# 
dell@dell:~$ cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
* Applying /usr/lib/sysctl.d/10-apparmor.conf ...
* Applying /etc/sysctl.d/10-bufferbloat.conf ...
* Applying /etc/sysctl.d/10-console-messages.conf ...
* Applying /etc/sysctl.d/10-ipv6-privacy.conf ...
* Applying /etc/sysctl.d/10-kernel-hardening.conf ...
* Applying /etc/sysctl.d/10-magic-sysrq.conf ...
* Applying /etc/sysctl.d/10-map-count.conf ...
* Applying /etc/sysctl.d/10-network-security.conf ...
* Applying /etc/sysctl.d/10-ptrace.conf ...
* Applying /etc/sysctl.d/10-zeropage.conf ...
* Applying /usr/lib/sysctl.d/50-pid-max.conf ...
* Applying /etc/sysctl.d/99-enroot.conf ...
* Applying /usr/lib/sysctl.d/99-protect-links.conf ...
* Applying /etc/sysctl.d/99-sysctl.conf ...
* Applying /etc/sysctl.d/k8s.conf ...
* Applying /etc/sysctl.conf ...
kernel.apparmor_restrict_unprivileged_userns = 1
net.core.default_qdisc = fq_codel
kernel.printk = 4 4 1 7
net.ipv6.conf.all.use_tempaddr = 2
net.ipv6.conf.default.use_tempaddr = 2
kernel.kptr_restrict = 1
kernel.sysrq = 176
vm.max_map_count = 1048576
net.ipv4.conf.default.rp_filter = 2
net.ipv4.conf.all.rp_filter = 2
kernel.yama.ptrace_scope = 1
vm.mmap_min_addr = 65536
kernel.pid_max = 4194304
kernel.apparmor_restrict_unprivileged_userns = 0
fs.protected_fifos = 1
fs.protected_hardlinks = 1
fs.protected_regular = 2
fs.protected_symlinks = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
dell@dell:~$

# 3) Containerfmf k8s용으로 설정 (Docker CE에 포함된 containerd 재사용)
dell@dell:~$ sudo swapoff -a
dell@dell:~$ sudo sed -i '/ swap / s/^/#/' /etc/fstab
dell@dell:~$ sudo mkdir -p /etc/containerd
dell@dell:~$ containerd config default | sudo tee /etc/containerd/config.toml
version = 4
root = '/var/lib/containerd'
state = '/run/containerd'
temp = ''
disabled_plugins = []
required_plugins = []
oom_score = 0
imports = ['/etc/containerd/conf.d/*.toml']

[debug]
  level = ''
  format = ''
  log_trace_id = false

[plugins]
  [plugins.'io.containerd.cri.v1.images']
    snapshotter = 'overlayfs'
    disable_snapshot_annotations = true
    discard_unpacked_layers = false
    max_concurrent_downloads = 3
    concurrent_layer_fetch_buffer = 0
    image_pull_progress_timeout = '5m0s'
    image_pull_with_sync_fs = false
    stats_collect_period = 10
    use_local_image_pull = false

    [plugins.'io.containerd.cri.v1.images'.pinned_images]
      sandbox = 'registry.k8s.io/pause:3.10.2'

    [plugins.'io.containerd.cri.v1.images'.registry]
      config_path = ''

    [plugins.'io.containerd.cri.v1.images'.image_decryption]
      key_model = 'node'

  [plugins.'io.containerd.cri.v1.runtime']
    enable_selinux = false
    selinux_category_range = 1024
    max_container_log_line_size = 16384
    disable_apparmor = false
    restrict_oom_score_adj = false
    disable_proc_mount = false
    unset_seccomp_profile = ''
    tolerate_missing_hugetlb_controller = true
    disable_hugetlb_controller = true
    device_ownership_from_security_context = false
    ignore_image_defined_volumes = false
    netns_mounts_under_state_dir = false
    enable_unprivileged_ports = true
    enable_unprivileged_icmp = true
    enable_cdi = true
    cdi_spec_dirs = ['/etc/cdi', '/var/run/cdi']
    drain_exec_sync_io_timeout = '0s'
    ignore_deprecation_warnings = []
    stats_collect_period = ''
    stats_retention_period = ''

    [plugins.'io.containerd.cri.v1.runtime'.containerd]
      default_runtime_name = 'runc'
      ignore_blockio_not_enabled_errors = false
      ignore_rdt_not_enabled_errors = false

      [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes]
        [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc]
          runtime_type = 'io.containerd.runc.v2'
          runtime_path = ''
          pod_annotations = []
          container_annotations = []
          privileged_without_host_devices = false
          privileged_without_host_devices_all_devices_allowed = false
          cgroup_writable = false
          base_runtime_spec = ''
          cni_conf_dir = ''
          cni_max_conf_num = 0
          snapshotter = ''
          sandboxer = 'podsandbox'
          io_type = ''

          [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc.options]
            BinaryName = ''
            CriuImagePath = ''
            CriuWorkPath = ''
            IoGid = 0
            IoUid = 0
            NoNewKeyring = false
            Root = ''
            ShimCgroup = ''
            SystemdCgroup = false

    [plugins.'io.containerd.cri.v1.runtime'.cni]
      bin_dir = ''
      bin_dirs = ['/opt/cni/bin']
      conf_dir = '/etc/cni/net.d'
      max_conf_num = 1
      setup_serially = false
      conf_template = ''
      ip_pref = ''
      use_internal_loopback = false

  [plugins.'io.containerd.differ.v1.erofs']
    mkfs_options = []
    enable_tar_index = false
    enable_dmverity = false

  [plugins.'io.containerd.gc.v1.scheduler']
    pause_threshold = 0.02
    deletion_threshold = 0
    mutation_threshold = 100
    schedule_delay = '0s'
    startup_delay = '100ms'

  [plugins.'io.containerd.grpc.v1.cri']
    disable_tcp_service = true
    stream_server_address = '127.0.0.1'
    stream_server_port = '0'
    stream_idle_timeout = '4h0m0s'
    enable_tls_streaming = false

    [plugins.'io.containerd.grpc.v1.cri'.x509_key_pair_streaming]
      tls_cert_file = ''
      tls_key_file = ''

  [plugins.'io.containerd.image-verifier.v1.bindir']
    bin_dir = '/opt/containerd/image-verifier/bin'
    max_verifiers = 10
    per_verifier_timeout = '10s'

  [plugins.'io.containerd.internal.v1.opt']
    path = '/opt/containerd'

  [plugins.'io.containerd.internal.v1.tracing']

  [plugins.'io.containerd.metadata.v1.bolt']
    content_sharing_policy = 'shared'
    no_sync = false

  [plugins.'io.containerd.metrics.v1.grpc-prometheus']
    grpc_histogram = false

  [plugins.'io.containerd.monitor.container.v1.restart']
    interval = '10s'

  [plugins.'io.containerd.monitor.task.v1.cgroups']
    no_prometheus = false

  [plugins.'io.containerd.mount-handler.v1.erofs']

  [plugins.'io.containerd.nri.v1.nri']
    disable = false
    socket_path = '/var/run/nri/nri.sock'
    plugin_path = '/opt/nri/plugins'
    plugin_config_path = '/etc/nri/conf.d'
    plugin_registration_timeout = '5s'
    plugin_request_timeout = '2s'
    disable_connections = false

    [plugins.'io.containerd.nri.v1.nri'.default_validator]
      enable = false
      reject_oci_hook_adjustment = false
      reject_runtime_default_seccomp_adjustment = false
      reject_unconfined_seccomp_adjustment = false
      reject_custom_seccomp_adjustment = false
      reject_namespace_adjustment = false
      reject_sysctl_adjustment = false
      required_plugins = []
      tolerate_missing_plugins_annotation = ''

  [plugins.'io.containerd.runtime.v2.task']
    platforms = ['linux/amd64']

  [plugins.'io.containerd.server.v1.debug']
    address = ''
    uid = 0
    gid = 0

  [plugins.'io.containerd.server.v1.grpc']
    address = '/run/containerd/containerd.sock'
    uid = 1000
    gid = 1000
    max_recv_message_size = 16777216
    max_send_message_size = 16777216

  [plugins.'io.containerd.server.v1.grpc-tcp']
    address = ''
    tls_ca = ''
    tls_cert = ''
    tls_key = ''
    tls_common_name = ''
    max_recv_message_size = 16777216
    max_send_message_size = 16777216

  [plugins.'io.containerd.server.v1.metrics']
    address = ''

  [plugins.'io.containerd.server.v1.ttrpc']
    address = '/run/containerd/containerd.sock.ttrpc'
    uid = 1000
    gid = 1000

  [plugins.'io.containerd.service.v1.diff-service']
    default = ['walking']
    sync_fs = false

  [plugins.'io.containerd.service.v1.tasks-service']
    blockio_config_file = ''
    rdt_config_file = ''

  [plugins.'io.containerd.shim.v1.manager']
    env = []
    socket_dir = ''

  [plugins.'io.containerd.snapshotter.v1.blockfile']
    root_path = ''
    scratch_file = ''
    fs_type = ''
    mount_options = []
    recreate_scratch = false

  [plugins.'io.containerd.snapshotter.v1.btrfs']
    root_path = ''

  [plugins.'io.containerd.snapshotter.v1.devmapper']
    root_path = ''
    pool_name = ''
    base_image_size = ''
    async_remove = false
    discard_blocks = false
    fs_type = ''
    fs_options = ''

  [plugins.'io.containerd.snapshotter.v1.erofs']
    root_path = ''
    ovl_mount_options = []
    enable_fsverity = false
    set_immutable = false
    default_size = ''
    dmverity_mode = ''

  [plugins.'io.containerd.snapshotter.v1.native']
    root_path = ''

  [plugins.'io.containerd.snapshotter.v1.overlayfs']
    root_path = ''
    upperdir_label = false
    sync_remove = false
    slow_chown = false
    mount_options = []

  [plugins.'io.containerd.snapshotter.v1.zfs']
    root_path = ''

  [plugins.'io.containerd.tracing.processor.v1.otlp']

  [plugins.'io.containerd.transfer.v1.local']
    max_concurrent_downloads = 3
    concurrent_layer_fetch_buffer = 0
    max_concurrent_uploaded_layers = 3
    check_platform_supported = false
    config_path = ''
    max_concurrent_unpacks = 1

[cgroup]
  path = ''

[timeouts]
  'io.containerd.timeout.bolt.open' = '0s'
  'io.containerd.timeout.cri.defercleanup' = '1m0s'
  'io.containerd.timeout.metrics.shimstats' = '2s'
  'io.containerd.timeout.shim.cleanup' = '5s'
  'io.containerd.timeout.shim.load' = '5s'
  'io.containerd.timeout.shim.shutdown' = '3s'
  'io.containerd.timeout.task.state' = '2s'

[stream_processors]
  [stream_processors.'io.containerd.ocicrypt.decoder.v1.tar']
    accepts = ['application/vnd.oci.image.layer.v1.tar+encrypted']
    returns = 'application/vnd.oci.image.layer.v1.tar'
    path = 'ctd-decoder'
    args = ['--decryption-keys-path', '/etc/containerd/ocicrypt/keys']
    env = ['OCICRYPT_KEYPROVIDER_CONFIG=/etc/containerd/ocicrypt/ocicrypt_keyprovider.conf']

  [stream_processors.'io.containerd.ocicrypt.decoder.v1.tar.gzip']
    accepts = ['application/vnd.oci.image.layer.v1.tar+gzip+encrypted']
    returns = 'application/vnd.oci.image.layer.v1.tar+gzip'
    path = 'ctd-decoder'
    args = ['--decryption-keys-path', '/etc/containerd/ocicrypt/keys']
    env = ['OCICRYPT_KEYPROVIDER_CONFIG=/etc/containerd/ocicrypt/ocicrypt_keyprovider.conf']

# SystemdCgroup = true 로 변경 (kubelet과 cgroup 드라이버 일치시킴)
dell@dell:~$ sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
dell@dell:~$ sudo systemctl restart containerd

# 4) kubeadm/kubelet/kubectl 설치 (최신 stable 채널 기준, 버전은 필요시 조정)
dell@dell:~$ sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
dell@dell:~$ sudo systemctl restart containerd
dell@dell:~$ sudo apt-get update
Hit:1 https://nvidia.github.io/libnvidia-container/stable/deb/amd64  InRelease
Hit:2 http://kr.archive.ubuntu.com/ubuntu noble InRelease
Get:3 http://kr.archive.ubuntu.com/ubuntu noble-updates InRelease [126 kB]
Get:4 http://security.ubuntu.com/ubuntu noble-security InRelease [126 kB]
Hit:5 https://download.docker.com/linux/ubuntu noble InRelease
Get:6 http://kr.archive.ubuntu.com/ubuntu noble-backports InRelease [126 kB]
Get:7 http://kr.archive.ubuntu.com/ubuntu noble-updates/main amd64 Components [180 kB]
Get:8 http://kr.archive.ubuntu.com/ubuntu noble-updates/universe amd64 Components [388 kB]
Get:9 http://kr.archive.ubuntu.com/ubuntu noble-updates/multiverse amd64 Components [940 B]
Get:10 http://kr.archive.ubuntu.com/ubuntu noble-backports/main amd64 Components [5,760 B]
Get:11 http://kr.archive.ubuntu.com/ubuntu noble-backports/universe amd64 Components [12.7 kB]
Get:12 http://security.ubuntu.com/ubuntu noble-security/main amd64 Components [46.3 kB]
Get:13 http://security.ubuntu.com/ubuntu noble-security/universe amd64 Components [76.3 kB]
Hit:14 https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64  InRelease
Fetched 1,089 kB in 4s (303 kB/s)
Reading package lists... Done
dell@dell:~$ sudo apt-get install -y apt-transport-https ca-certificates curl gpg
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
ca-certificates is already the newest version (20260601~24.04.1).
curl is already the newest version (8.5.0-2ubuntu10.13).
gpg is already the newest version (2.4.4-2ubuntu17.4).
gpg set to manually installed.
The following NEW packages will be installed:
  apt-transport-https
0 upgraded, 1 newly installed, 0 to remove and 45 not upgraded.
Need to get 3,970 B of archives.
After this operation, 36.9 kB of additional disk space will be used.
Get:1 http://kr.archive.ubuntu.com/ubuntu noble-updates/universe amd64 apt-transport-https all 2.8.3 [3,970 B]
Fetched 3,970 B in 0s (31.4 kB/s)
Selecting previously unselected package apt-transport-https.
(Reading database ... 155010 files and directories currently installed.)
Preparing to unpack .../apt-transport-https_2.8.3_all.deb ...
Unpacking apt-transport-https (2.8.3) ...
Setting up apt-transport-https (2.8.3) ...
Scanning processes...
Scanning candidates...
Scanning processor microcode...
Scanning linux images...

Running kernel seems to be up-to-date.

The processor microcode seems to be up-to-date.

Restarting services...
 systemctl restart slurmd.service

Service restarts being deferred:
 systemctl restart systemd-logind.service
 systemctl restart unattended-upgrades.service

No containers need to be restarted.

User sessions running outdated binaries:
 dell @ session #1: login[5456]
 dell @ user manager service: systemd[5761]

No VM guests are running outdated hypervisor (qemu) binaries on this host.
dell@dell:~$ curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
dell@dell:~$ echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /
dell@dell:~$ sudo apt-get update
Hit:1 https://nvidia.github.io/libnvidia-container/stable/deb/amd64  InRelease
Hit:3 http://kr.archive.ubuntu.com/ubuntu noble InRelease
Hit:4 http://kr.archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:5 http://kr.archive.ubuntu.com/ubuntu noble-backports InRelease
Hit:6 https://download.docker.com/linux/ubuntu noble InRelease
Hit:7 https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64  InRelease
Hit:8 http://security.ubuntu.com/ubuntu noble-security InRelease
Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  InRelease [1,192 B]
Get:9 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  Packages [20.8 kB]
Fetched 22.0 kB in 2s (14.6 kB/s)
Reading package lists... Done
dell@dell:~$ sudo apt-get install -y kubelet kubeadm kubectl
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  cri-tools kubernetes-cni
The following NEW packages will be installed:
  cri-tools kubeadm kubectl kubelet kubernetes-cni
0 upgraded, 5 newly installed, 0 to remove and 45 not upgraded.
Need to get 88.1 MB of archives.
After this operation, 317 MB of additional disk space will be used.
Get:1 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  cri-tools 1.31.1-1.1 [15.7 MB]
Get:2 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  kubeadm 1.31.14-1.1 [11.6 MB]
Get:3 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  kubectl 1.31.14-1.1 [11.5 MB]
Get:4 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  kubernetes-cni 1.5.1-1.1 [33.9 MB]
Get:5 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  kubelet 1.31.14-1.1 [15.4 MB]
Fetched 88.1 MB in 10s (9,214 kB/s)
Selecting previously unselected package cri-tools.
(Reading database ... 155014 files and directories currently installed.)
Preparing to unpack .../cri-tools_1.31.1-1.1_amd64.deb ...
Unpacking cri-tools (1.31.1-1.1) ...
Selecting previously unselected package kubeadm.
Preparing to unpack .../kubeadm_1.31.14-1.1_amd64.deb ...
Unpacking kubeadm (1.31.14-1.1) ...
Selecting previously unselected package kubectl.
Preparing to unpack .../kubectl_1.31.14-1.1_amd64.deb ...
Unpacking kubectl (1.31.14-1.1) ...
Selecting previously unselected package kubernetes-cni.
Preparing to unpack .../kubernetes-cni_1.5.1-1.1_amd64.deb ...
Unpacking kubernetes-cni (1.5.1-1.1) ...
Selecting previously unselected package kubelet.
Preparing to unpack .../kubelet_1.31.14-1.1_amd64.deb ...
Unpacking kubelet (1.31.14-1.1) ...
Setting up kubectl (1.31.14-1.1) ...
Setting up cri-tools (1.31.1-1.1) ...
Setting up kubernetes-cni (1.5.1-1.1) ...
Setting up kubeadm (1.31.14-1.1) ...
Setting up kubelet (1.31.14-1.1) ...
Scanning processes...
Scanning candidates...
Scanning processor microcode...
Scanning linux images...

Running kernel seems to be up-to-date.

The processor microcode seems to be up-to-date.

Restarting services...
 systemctl restart slurmd.service

Service restarts being deferred:
 systemctl restart systemd-logind.service
 systemctl restart unattended-upgrades.service

No containers need to be restarted.

User sessions running outdated binaries:
 dell @ session #1: login[5456]
 dell @ user manager service: systemd[5761]

No VM guests are running outdated hypervisor (qemu) binaries on this host.
dell@dell:~$ sudo apt-mark hold kubelet kubeadm kubectl
kubelet set on hold.
kubeadm set on hold.
kubectl set on hold.

# 5) 클러스터 초기화 (단일노드, pod network CIDR은 Calico 기본값)
dell@dell:~$ sudo kubeadm init --pod-network-cidr=192.168.0.0/16
I0831 05:16:35.168018  576090 version.go:261] remote version is much newer: v1.37.0; falling back to: stable-1.31
[init] Using Kubernetes version: v1.31.14
[preflight] Running pre-flight checks
error execution phase preflight: [preflight] Some fatal errors occurred:
        [ERROR FileExisting-conntrack]: conntrack not found in system path
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
To see the stack trace of this error execute with --v=5 or higher
dell@dell:~$ mkdir -p $HOME/.kube
dell@dell:~$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
cp: cannot stat '/etc/kubernetes/admin.conf': No such file or directory
dell@dell:~$ sudo apt-get update
Hit:1 http://kr.archive.ubuntu.com/ubuntu noble InRelease
Hit:2 http://kr.archive.ubuntu.com/ubuntu noble-updates InRelease
Hit:3 http://kr.archive.ubuntu.com/ubuntu noble-backports InRelease
Hit:4 https://nvidia.github.io/libnvidia-container/stable/deb/amd64  InRelease
Hit:6 https://download.docker.com/linux/ubuntu noble InRelease
Hit:7 http://security.ubuntu.com/ubuntu noble-security InRelease
Hit:5 https://prod-cdn.packages.k8s.io/repositories/isv:/kubernetes:/core:/stable:/v1.31/deb  InRelease
Hit:8 https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64  InRelease
Reading package lists... Done
dell@dell:~$ sudo apt-get install -y conntrack
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  conntrack
0 upgraded, 1 newly installed, 0 to remove and 45 not upgraded.
Need to get 37.9 kB of archives.
After this operation, 119 kB of additional disk space will be used.
Get:1 http://kr.archive.ubuntu.com/ubuntu noble/main amd64 conntrack amd64 1:1.4.8-1ubuntu1 [37.9 kB]
Fetched 37.9 kB in 0s (261 kB/s)
Selecting previously unselected package conntrack.
(Reading database ... 155067 files and directories currently installed.)
Preparing to unpack .../conntrack_1%3a1.4.8-1ubuntu1_amd64.deb ...
Unpacking conntrack (1:1.4.8-1ubuntu1) ...
Setting up conntrack (1:1.4.8-1ubuntu1) ...
Processing triggers for man-db (2.12.0-4build2) ...
Scanning processes...
Scanning candidates...
Scanning processor microcode...
Scanning linux images...

Running kernel seems to be up-to-date.

The processor microcode seems to be up-to-date.

Restarting services...
 systemctl restart slurmd.service

 # conntrack 설치 후 다시 시도
 dell@dell:~$ sudo kubeadm init --pod-network-cidr=192.168.0.0/16
I0831 05:20:30.283664  577133 version.go:261] remote version is much newer: v1.37.0; falling back to: stable-1.31
[init] Using Kubernetes version: v1.31.14
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action beforehand using 'kubeadm config images pull'
W0831 05:20:30.420733  577133 checks.go:843] detected that the sandbox image "" of the container runtime is inconsistent with that used by kubeadm.It is recommended to use "registry.k8s.io/pause:3.10" as the CRI sandbox image.
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [dell kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 10.118.103.98]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [dell localhost] and IPs [10.118.103.98 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [dell localhost] and IPs [10.118.103.98 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "super-admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests"
[kubelet-check] Waiting for a healthy kubelet at http://127.0.0.1:10248/healthz. This can take up to 4m0s
[kubelet-check] The kubelet is healthy after 504.14953ms
[api-check] Waiting for a healthy API server. This can take up to 4m0s
[api-check] The API server is healthy after 7.00243495s
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node dell as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node dell as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
[bootstrap-token] Using token: 3c3yrj.r41pzvq11s1eoujj
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.118.103.98:6443 --token 3c3yrj.r41pzvq11s1eoujj \
        --discovery-token-ca-cert-hash sha256:7beb2091761fedfdb9a372b4499c19e1d34a98b338c541ceb0818a382a29dc35


# 6) kubectl 사용자 설정
dell@dell:~$ ls $HOME/.kube/
dell@dell:~$ ls -al $HOME/.kube/
total 8
drwxrwxr-x  2 dell dell 4096 Aug 31 05:17 .
drwxr-x--- 16 dell dell 4096 Aug 31 05:19 ..
dell@dell:~$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
dell@dell:~$ ls -al $HOME/.kube/
total 16
drwxrwxr-x  2 dell dell 4096 Aug 31 05:23 .
drwxr-x--- 16 dell dell 4096 Aug 31 05:19 ..
-rw-------  1 root root 5657 Aug 31 05:23 config
dell@dell:~$ sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 7) CNI(Calico) 설치
dell@dell:~$ kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml
poddisruptionbudget.policy/calico-kube-controllers created
serviceaccount/calico-kube-controllers created
serviceaccount/calico-node created
serviceaccount/calico-cni-plugin created
configmap/calico-config created
customresourcedefinition.apiextensions.k8s.io/bgpconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/bgpfilters.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/bgppeers.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/blockaffinities.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/caliconodestatuses.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/clusterinformations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/felixconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworksets.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/hostendpoints.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamblocks.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamconfigs.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamhandles.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ippools.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipreservations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/kubecontrollersconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/networkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/networksets.crd.projectcalico.org created
clusterrole.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrole.rbac.authorization.k8s.io/calico-node created
clusterrole.rbac.authorization.k8s.io/calico-cni-plugin created
clusterrolebinding.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrolebinding.rbac.authorization.k8s.io/calico-node created
clusterrolebinding.rbac.authorization.k8s.io/calico-cni-plugin created
daemonset.apps/calico-node created
deployment.apps/calico-kube-controllers created

# 8) 단일 노드에서 워크로드 스케줄 허용 (마스터 taint 제거)
dell@dell:~$ kubectl taint nodes --all node-role.kubernetes.io/control-plane-
node/dell untainted

# 9) 확인
dell@dell:~$ kubectl get nodes -o wide
NAME   STATUS     ROLES           AGE     VERSION    INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
dell   NotReady   control-plane   3m51s   v1.31.14   10.118.103.98   <none>        Ubuntu 24.04.4 LTS   6.8.0-138-generic   containerd://2.3.3
dell@dell:~$ kubectl get node -A
NAME   STATUS   ROLES           AGE    VERSION
dell   Ready    control-plane   4m6s   v1.31.14
```



## 4. Helm 설치 (GPU Operator 배포에 필요)
```bash
# Helm 설치 (GPU Operator 배포에 필요)

dell@dell:~$ curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 12252  100 12252    0     0   427k      0 --:--:-- --:--:-- --:--:--  443k
Downloading https://get.helm.sh/helm-v3.21.4-linux-amd64.tar.gz
Verifying checksum... Done.
Preparing to install helm into /usr/local/bin
helm installed into /usr/local/bin/helm

dell@dell:~$ helm version
version.BuildInfo{Version:"v3.21.4", GitCommit:"813176c51bb5c181dbbd7901298ddcc104cd3417", GitTreeState:"clean", GoVersion:"go1.26.5"}
```

## 5. NVIDIA GPU Operator 설치
```bash
dell@dell:~$ helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
"nvidia" has been added to your repositories
dell@dell:~$ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "nvidia" chart repository
Update Complete. ⎈Happy Helming!⎈

# create namespace gpu-operator 
dell@dell:~$ kubectl create namespace gpu-operator
namespace/gpu-operator created

# helm install 
dell@dell:~$ helm install gpu-operator nvidia/gpu-operator \
  -n gpu-operator \
  --set driver.enabled=false \
  --set toolkit.enabled=false \
  --set devicePlugin.enabled=true \
  --set dcgmExporter.enabled=true \
  --set nfd.enabled=true
NAME: gpu-operator
LAST DEPLOYED: Mon Aug 31 05:33:46 2026
NAMESPACE: gpu-operator
STATUS: deployed
REVISION: 1
TEST SUITE: None

# gpu-operator pods monitoring
dell@dell:~$ kubectl get pods -n gpu-operator -w
NAME                                                          READY   STATUS     RESTARTS   AGE
gpu-feature-discovery-9j5c7                                   0/1     Init:0/1   0          37s
gpu-operator-748895f689-m54cp                                 1/1     Running    0          63s
gpu-operator-node-feature-discovery-gc-59cb65b6cb-qr77s       1/1     Running    0          63s
gpu-operator-node-feature-discovery-master-5d5d6b87c4-hxnb9   1/1     Running    0          63s
gpu-operator-node-feature-discovery-worker-bbrps              1/1     Running    0          63s
nvidia-dcgm-exporter-j4r26                                    0/1     Init:0/1   0          37s
nvidia-device-plugin-daemonset-p76kl                          0/1     Init:0/1   0          37s
nvidia-operator-validator-vw9np                               0/1     Init:0/4   0          37s

# operator pods initial






