# XE9780 (B300 x7) — K8s 기반 모델 배포 + AI Perf 테스트 가이드

> 전제: driver 610.57.04 / CUDA 13.3 / nvidia-container-toolkit 1.20.0 / Docker 29.7.2 는 이미 설치됨 (README.md Phase 1 참고).
> 이 문서는 **그 위에 K8s를 얹고, GPU를 스케줄링 가능한 리소스로 노출시킨 뒤, 모델을 컨테이너로 배포하고, genai-perf(AI Perf)로 부하테스트**하는 전 과정입니다.
> 명령어는 순서대로 한 줄씩 실행하면 되도록 구성했습니다. `sudo` 필요한 곳은 표시했습니다.

---

## 0. 사전 점검

```bash
# GPU, 드라이버, 컨테이너 툴킷이 살아있는지 재확인
nvidia-smi
nvidia-ctk --version
docker info | grep -i runtime
```

기대 결과: GPU 7장 표시, `nvidia` 런타임이 `Runtimes:` 목록에 존재.

---

## 1. 단일 노드 K8s 설치 (kubeadm)

랙 하나짜리 단일 노드라면 k3s가 더 가볍지만, GPU Operator/DCGM exporter 호환성 기준으로는 **kubeadm 표준 K8s**를 추천합니다. (k3s를 원하면 1-B로 대체 가능)

### 1-A. kubeadm 방식

```bash
# 1) 커널 모듈 & sysctl (K8s 네트워킹 요구사항)
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# 2) swap 비활성화 (kubelet 필수 조건)
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# 3) containerd를 K8s용으로 설정 (Docker CE에 포함된 containerd 재사용)
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml
# SystemdCgroup = true 로 변경 (kubelet과 cgroup 드라이버 일치시킴)
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

# 4) kubeadm/kubelet/kubectl 설치 (최신 stable 채널 기준, 버전은 필요시 조정)
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# 5) 클러스터 초기화 (단일노드, pod network CIDR은 Calico 기본값)
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

# 6) kubectl 사용자 설정
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 7) CNI(Calico) 설치
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/calico.yaml

# 8) 단일 노드에서 워크로드 스케줄 허용 (마스터 taint 제거)
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

# 9) 확인
kubectl get nodes -o wide
kubectl get pods -A
```

### 1-B. (대안) k3s로 더 가볍게

```bash
curl -sfL https://get.k3s.io | sh -
sudo cat /etc/rancher/k3s/k3s.yaml   # kubeconfig
mkdir -p ~/.kube && sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
kubectl get nodes
```
k3s 사용 시 아래 GPU Operator 설치에서 `-set containerd.runtimeClass=nvidia` 등 k3s 전용 옵션이 필요합니다. 이 문서는 이후 표준 kubeadm 기준으로 진행합니다.

---

## 2. Helm 설치 (GPU Operator 배포에 필요)

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

---

## 3. NVIDIA GPU Operator 설치

드라이버는 **이미 호스트에 수동 설치되어 있으므로**, GPU Operator가 드라이버를 또 설치하지 않도록 `driver.enabled=false`로 설치합니다. (Operator는 device-plugin, DCGM exporter, container-toolkit 검증, feature-discovery만 담당하게 됨)

```bash
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update

kubectl create namespace gpu-operator

helm install gpu-operator nvidia/gpu-operator \
  -n gpu-operator \
  --set driver.enabled=false \
  --set toolkit.enabled=false \
  --set devicePlugin.enabled=true \
  --set dcgmExporter.enabled=true \
  --set nfd.enabled=true

# 배포 상태 확인 (전부 Running 될 때까지 수 분 소요)
kubectl get pods -n gpu-operator -w
```

> `toolkit.enabled=false`인 이유: nvidia-container-toolkit도 이미 호스트에 1.20.0으로 설치돼 있고 `docker info`에서 `nvidia` 런타임이 확인됐기 때문입니다. containerd에도 nvidia 런타임이 등록돼 있는지 아래에서 확인/등록합니다.

```bash
# containerd에 nvidia 런타임 등록 확인 (k8s는 containerd를 통해 컨테이너를 뜨므로 여기 등록이 핵심)
sudo nvidia-ctk runtime configure --runtime=containerd --set-as-default
sudo systemctl restart containerd
kubectl delete pod -n gpu-operator -l app=nvidia-device-plugin-daemonset   # 재기동시켜 새 런타임 인식
```

### 3-1. GPU가 K8s 리소스로 잡히는지 확인

```bash
kubectl describe node $(hostname) | grep -A5 "Allocatable:"
# nvidia.com/gpu: 7  로 보이면 성공
```

7이 아니라 8이나 0으로 보이면 → device-plugin daemonset 로그 확인:
```bash
kubectl logs -n gpu-operator -l app=nvidia-device-plugin-daemonset
```

---

## 4. GPU가 실제로 파드에서 잡히는지 스모크 테스트

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: gpu-smoke-test
spec:
  restartPolicy: Never
  containers:
  - name: cuda-check
    image: nvidia/cuda:13.0.0-base-ubuntu24.04
    command: ["nvidia-smi"]
    resources:
      limits:
        nvidia.com/gpu: 1
EOF

kubectl wait --for=condition=Ready pod/gpu-smoke-test --timeout=120s || true
kubectl logs gpu-smoke-test
kubectl delete pod gpu-smoke-test
```
`nvidia-smi` 출력에 GPU 1장이 보이면 K8s → 컨테이너로 GPU 패스스루가 정상 동작하는 것입니다.

---

## 5. 모델 서빙 컨테이너 배포 (vLLM, OpenAI 호환 API)

AI Perf(genai-perf)는 **OpenAI 호환 `/v1/completions` 또는 `/v1/chat/completions` 엔드포인트**를 대상으로 부하를 걸도록 설계되어 있습니다. 가장 손이 덜 가는 조합은 **vLLM 서빙 컨테이너**입니다. (Triton+TensorRT-LLM도 가능하지만 엔진 빌드 단계가 추가로 필요해 훨씬 오래 걸림 — 우선 vLLM으로 빠르게 기준선을 잡는 걸 추천)

> B300(Blackwell Ultra, sm_100대)은 최신 아키텍처라 **vLLM 최신 릴리스 이미지(CUDA 12.8+/13 지원 버전) 사용이 중요**합니다. 오래된 태그는 커널을 못 띄울 수 있습니다.

### 5-1. 모델 저장용 PVC (모델 가중치를 노드 로컬 디스크에 유지)

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: model-cache-pv
spec:
  capacity:
    storage: 500Gi
  accessModes: ["ReadWriteOnce"]
  hostPath:
    path: /data/model-cache
    type: DirectoryOrCreate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: model-cache-pvc
spec:
  accessModes: ["ReadWriteOnce"]
  resources:
    requests:
      storage: 500Gi
  volumeName: model-cache-pv
EOF
```

### 5-2. Hugging Face 토큰 시크릿 (gated 모델 쓸 경우만)

```bash
kubectl create secret generic hf-token --from-literal=token=YOUR_HF_TOKEN
```

### 5-3. vLLM Deployment + Service

아래는 예시로 `meta-llama/Llama-3.1-8B-Instruct`를 7개 중 1개 GPU에 올리는 구성입니다. 모델/GPU 개수는 필요에 맞게 바꾸세요 (`tensor-parallel-size`로 여러 GPU 분산 가능).

```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-server
spec:
  replicas: 1
  selector:
    matchLabels: { app: vllm-server }
  template:
    metadata:
      labels: { app: vllm-server }
    spec:
      containers:
      - name: vllm
        image: vllm/vllm-openai:latest
        args:
          - "--model=meta-llama/Llama-3.1-8B-Instruct"
          - "--tensor-parallel-size=1"
          - "--gpu-memory-utilization=0.90"
          - "--port=8000"
        env:
        - name: HUGGING_FACE_HUB_TOKEN
          valueFrom:
            secretKeyRef: { name: hf-token, key: token }
        - name: HF_HOME
          value: /model-cache
        ports:
        - containerPort: 8000
        resources:
          limits:
            nvidia.com/gpu: 1
        volumeMounts:
        - name: model-cache
          mountPath: /model-cache
        - name: shm
          mountPath: /dev/shm
      volumes:
      - name: model-cache
        persistentVolumeClaim: { claimName: model-cache-pvc }
      - name: shm
        emptyDir: { medium: Memory, sizeLimit: 16Gi }
---
apiVersion: v1
kind: Service
metadata:
  name: vllm-server
spec:
  selector: { app: vllm-server }
  ports:
  - port: 8000
    targetPort: 8000
  type: ClusterIP
EOF
```

### 5-4. 배포 확인

```bash
kubectl get pods -l app=vllm-server -w
# 최초 기동 시 모델 다운로드(수 GB~수십 GB)로 수 분~수십 분 걸릴 수 있음
kubectl logs -f -l app=vllm-server
# "Uvicorn running on http://0.0.0.0:8000" 뜨면 서빙 준비 완료
```

### 5-5. 포트포워딩으로 헬스체크

```bash
kubectl port-forward svc/vllm-server 8000:8000 &

curl http://localhost:8000/v1/models

curl http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "meta-llama/Llama-3.1-8B-Instruct",
    "messages": [{"role":"user","content":"1+1은?"}],
    "max_tokens": 50
  }'
```

---

## 6. AI Perf (genai-perf) 설치 및 실행

`genai-perf`는 NVIDIA Perf Analyzer 기반의 LLM 서빙 부하테스트 도구로, OpenAI 호환 엔드포인트에 요청을 보내며 **TTFT(첫 토큰까지 지연), ITL(토큰간 지연), 처리량(req/s, tokens/s)** 등을 측정합니다.

### 6-1. genai-perf 컨테이너로 실행 (호스트에 직접 설치 안 해도 됨)

```bash
mkdir -p ~/aiperf_results

docker run --rm -it --net=host --gpus all \
  -v ~/aiperf_results:/results \
  nvcr.io/nvidia/tritonserver:24.10-py3-sdk \
  genai-perf profile \
    -m meta-llama/Llama-3.1-8B-Instruct \
    --service-kind openai \
    --endpoint-type chat \
    --url localhost:8000 \
    --streaming \
    --concurrency 10 \
    --num-prompts 200 \
    --synthetic-input-tokens-mean 200 \
    --synthetic-input-tokens-stddev 20 \
    --output-tokens-mean 200 \
    --output-tokens-stddev 20 \
    --artifact-dir /results
```

> 이미지 태그(`24.10-py3-sdk`)는 배포 시점 최신 것으로 바꾸세요. NGC 카탈로그(`nvcr.io/nvidia/tritonserver`)에서 `-sdk` 접미사가 붙은 태그를 찾으면 됩니다.

### 6-2. K8s 파드로 실행하고 싶은 경우

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: genai-perf-runner
spec:
  restartPolicy: Never
  containers:
  - name: genai-perf
    image: nvcr.io/nvidia/tritonserver:24.10-py3-sdk
    command: ["genai-perf", "profile",
      "-m", "meta-llama/Llama-3.1-8B-Instruct",
      "--service-kind", "openai",
      "--endpoint-type", "chat",
      "--url", "vllm-server:8000",
      "--streaming",
      "--concurrency", "10",
      "--num-prompts", "200"]
EOF

kubectl logs -f genai-perf-runner
```
(같은 클러스터 안이므로 `--url`은 Service 이름 `vllm-server:8000`으로 바로 접근 가능합니다.)

### 6-3. 결과 확인

```bash
cat ~/aiperf_results/*/profile_export_genai_perf.csv
# 또는
cat ~/aiperf_results/*/profile_export.json | python3 -m json.tool | less
```
핵심 확인 지표: `Time to First Token`, `Inter Token Latency`, `Request Throughput`, `Output Token Throughput`.

---

## 7. GPU 여러 장 확장 시 (Tensor Parallel)

7장 중 여러 장으로 하나의 큰 모델을 나눠 서빙하려면:

```bash
# Deployment의 args에서
"--tensor-parallel-size=4"
# 그리고 resources.limits.nvidia.com/gpu: 4 로 변경
```
NVLink로 GPU간 통신이 이뤄지므로(이미 topology 확인상 전 GPU가 NV18로 완전 연결됨), tensor-parallel 확장 시 통신 오버헤드는 크지 않을 것으로 예상됩니다.

---

## 8. 트러블슈팅 체크리스트

| 증상 | 확인 명령 |
|---|---|
| `nvidia.com/gpu` 리소스가 노드에 안 보임 | `kubectl logs -n gpu-operator -l app=nvidia-device-plugin-daemonset` |
| vLLM 파드가 GPU를 못 찾음 | `kubectl exec -it <pod> -- nvidia-smi` |
| 모델 다운로드가 안 됨(gated repo) | HF 토큰 시크릿 재확인, `huggingface-cli login` 필요 여부 확인 |
| genai-perf 접속 실패 | `kubectl get svc vllm-server`, `port-forward` 살아있는지 확인 |
| OOM (GPU 메모리 부족) | `--gpu-memory-utilization` 낮추기, `--max-model-len` 축소 |

---

## 참고
- vLLM 공식 문서: https://docs.vllm.ai
- GenAI-Perf 공식 문서: https://docs.nvidia.com/deeplearning/triton-inference-server/user-guide/docs/perf_analyzer/genai-perf/README.html
- NVIDIA GPU Operator: https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/index.html