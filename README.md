# kubernetes

# Kubeadm을 이용한 k8s 배포

> kubeadm 설치 문서
- kubeadm으로 kubernetes 클러스터 배포
- 버전 업그레이드
- 노드 추가
- 애드온(metallb, ingress, rook, metrics-server)

---

# Kubeadm 설치 문서

## 1. kubeadm으로 kubernetes 클러스터 배포

[Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

[kubeadm 설치하기](https://kubernetes.io/ko/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

### 1.1) docker, kubeadm, kubectl, kubelet 설치

- `kubeadm`: 클러스터를 부트스트랩하는 명령이다.
- `kubelet`: 클러스터의 모든 머신에서 실행되는 파드와 컨테이너 시작과 같은 작업을 수행하는 컴포넌트이다.
- `kubectl`: 클러스터와 통신하기 위한 커맨드 라인 유틸리티이다.

- 설치 시 version 지정가능
- kubernetes에서는 swap 사용하지 않음

```bash
# docker install
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
    
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# kubelet, kubeadm, kubectl install
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# find version
sudo apt-cache madison kubeadm

# version 지정 방법
# version: 1.18.19-00
sudo apt-get install -y kubelet=[version] kubeadm=[version] kubectl=[version]

sudo apt-mark hold kubelet kubeadm kubectl

# version 확인
kubeadm version
kubectl version
kubelet --version
```

### 1.2) cluster 생성

- control-plane에서 init → config 파일 생성

```bash
# kubeadm init
sudo kubeadm init --control-plane-endpoint [current_ip] --pod-network-cidr [current_cidr] --apiserver-advertise-address [current_ip]

# config 파일 생성
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

- cluster의 구성요소: control-plane, node, addon

## 2. 버전 업그레이드

[kubeadm 클러스터 업그레이드](https://kubernetes.io/ko/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)

### 2.1) 노드 업그레이드 순서

1. 기본 컨트롤 플레인 노드를 업그레이드한다.
2. 추가 컨트롤 플레인 노드를 업그레이드한다.
3. 워커(worker) 노드를 업그레이드한다.
- 버전 업그레이드는 한번에 1 단계 상위의 마이너 버전을 업그레이드 해야한다. (절대 한번에 두 단계는 뛰어넘지 못한다.)

### 2.1.1) control-plane upgrade

1. kubeadm (api, cm, sche, ccm ...)
2. kubectl / kubelet

```bash
# kubeadm upgrade
apt-get update && \
apt-get install -y --allow-change-held-packages kubeadm=1.18.20-00

kubeadm version
sudo kubeadm upgrade plan

# 워커노드가 아닌 control-plane에서만 실행하는 부분
sudo kubeadm upgrade apply v1.18.20

# kubelet, kubectl upgrade
apt-get update && \
    apt-get install -y --allow-change-held-packages kubelet=1.18.20-00 kubectl=1.18.20-00

kubectl version
kubelet --version

# kubelet만 유일하게 패키지로 설치했으므로 서비스 재시작
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

### 2.1.2) 워커노드 upgrade

1. kubeadm (proxy)
2. kubectl / kubelet

```bash
# kubeadm upgrade
apt-get update && \
apt-get install -y --allow-change-held-packages kubeadm=1.18.20-00

kubeadm version
sudo kubeadm upgrade plan

# control-plane과 유일하게 다른 부분
sudo kubeadm upgrade node

# kubelet, kubectl upgrade
apt-get update && \
    apt-get install -y --allow-change-held-packages kubelet=1.18.20-00 kubectl=1.18.20-00

kubectl version
kubelet --version

# kubelet만 유일하게 패키지로 설치했으므로 서비스 재시작
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

### 2.2) upgrade한 version 확인

```bash
kubectl get nodes
```

## 3. 노드 추가

### 3.1) Calico로 network add-on 해주기

[Install Calico networking and network policy for on-premises deployments](https://docs.projectcalico.org/getting-started/kubernetes/self-managed-onprem/onpremises)

- control-plane에서 실행

```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

### 3.2) join으로 노드 추가

- control-plane의 Port, Token, Hash값 필요 → 워커노드에서 join 실행

```bash
# Port
Kubernetes API server : 6443

# Token값 확인
kubeadm token list

# Hash값 확인
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'

# 워커노드에서 join 실행
sudo kubeadm join --token [token 값] [control-plane의 IP]:[Port] --discovery-token-ca-cert-hash sha256:[Hash 값]

# 추가된 node 확인
kubectl get nodes
```

- 모든 nodes Ready 상태 확인

## 4. Add-on (metallb, ingress, rook, metrics-server)

### 4.1) Metal-LB

[MetalLB](https://metallb.universe.tf/)

### 4.1.1) Manifest를 통한 설치

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/metallb.yam
```

### 4.1.2) metallb-config.yaml

```bash
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.200.200-192.168.200.210
```
---
### 4.2) ingress

### 4.2.1) 컨트롤러 설치

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.47.0/deploy/static/provider/baremetal/deploy.yaml

# 확인
kubectl get ns
```

### 4.2.2) 서비스 수정

```bash
kubectl edit svc -n ingress-nginx ingress-nginx-controller

spec: 밑에
externalIPs
- 192.168.200.51
- 192.168.200.52 (워커노드 IP)
추가해주기
```
---
### 4.3) rook-ceph

[Rook Docs](https://rook.io/docs/rook/v1.6/ceph-quickstart.html)

### 4.3.1) 빈 디스크가 있어야 함 (없으면 Vagrantfile 에서 새 디스크 할당)

### 4.3.2) ceph cluster 생성

```bash
git clone --single-branch --branch v1.6.7 [https://github.com/rook/rook.git](https://github.com/rook/rook.git)
cd rook/cluster/examples/kubernetes/ceph

# crds, common, operator 설치
kubectl create -f crds.yaml -f common.yaml -f operator.yaml

# cluster 생성
kubectl create -f cluster.yaml (3 worker)
또는
kubectl create -f cluster-test.yaml (1 worker)

# 확인 (꼭 현재 단계 완료된 후 블록 스토리지 생성으로 넘어갈 것)
kubectl -n rook-ceph get pod
```

### 4.3.3) 블록 스토리지 생성

[Rook Docs](https://rook.io/docs/rook/v1.6/ceph-block.html)

```bash
kubectl create -f csi/rbd/storageclass.yaml

# 확인
kubectl get sc
```

### 4.3.4) 파일 스토리지 생성

[Rook Docs](https://rook.io/docs/rook/v1.6/ceph-filesystem.html)

```bash
# 파일 시스템 생성
kubectl create -f filesystem.yaml (3 worker)
또는
kubectl create -f filesystem-test.yaml (1 worker)

# 파일 스토리지 생성
kubectl create -f csi/cephfs/storageclass.yaml
```

### 4.3.5) 최종 확인

```bash
# toolbox 생성
kubectl create -f toolbox.yaml

# health: HEALTH_WARN / HEALTH_OK 확인
kubectl -n rook-ceph exec deploy/rook-ceph-tools -- ceph -s
```

### 4.3.6) rook-ceph-block 스토리지 클래스를 기본 스토리지 클래스로 설정

```bash
kubectl patch storageclasses.storage.k8s.io rook-ceph-block -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# 확인
kubectl get sc -> (default)확인
```
---
### 4.4) metrics-server

[Release v0.5.0 · kubernetes-sigs/metrics-server](https://github.com/kubernetes-sigs/metrics-server/releases/tag/v0.5.0)

```bash
wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml

# metrics-server 파일 수정
vi components.yaml

# Deployment.spec.template.spec 영역에 추가
- --kubelet-insecure-tls

kubectl create -f components.yaml

# 확인
kubectl get po -n kube-system
kubectl describe po -n kube-system metrics-server-7fd898b97-cqjxr

# 노드와 파드 용량 확인
kubectl top nodes
kubectl top pods
```

---

---
