lsblk -f
git clone https://github.com/shkimm5189/k8s-install.git
s
ls
cd k8s-install/
ls
sh control.sh 
kubeadm version
kubectl version
ls
cd update/
ls
sh control-update.sh 
kubectl version
kubeadm version
ls -l ~/.kube/config
cd ..
ls
kubectl taint nodes --all node-role.kube
kubectl --version
kubelet --version
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl taint nodes --all node-role.kubernetes.io/master-
kubectl get nodes
kubeadm token list
penssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null |    openssl dgst -sha256 -hex | sed 's/^.* //'
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null |    openssl dgst -sha256 -hex | sed 's/^.* //'
kubectl get nodes
kubecl get pods -A
kubectl get pods -A
kubectl get nodes
ls
mkdir addon
ls
cd addon
ls
mkdir metallb
ls
cd metallb/
ls
vi config.yaml
cd ..
ls
vi .vimrc
cat .vimrc
cd addon/metallb/
ls
vi config.yaml
cd ..
vi .vimrc
cd addon/metallb/
ls
vi config.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/metallb.yaml
ls
kubectl apply -f config.yaml
vi config.yaml 
kubectl apply -f config.yaml
kubectl get all -n metallb-system
kubectl get ns
curl 192.168.200.200
cd ..
l
mkdir ingress
cd ingress/
ls
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.47.0/deploy/static/provider/baremetal/deploy.yaml
kubectl get all -n igres
kubectl get all -n ingress-niginx
kubectl get all -n ingress-nginx
kubectl edit svc -n ingress-nginx-controller
kubectl edit svc -n ingress-nginx ingress-nginx-controller
cd ..
ls
kubectl get nodes -o wide
echo "KUBELET_EXTRA_ARGS='--node-ip 192.168.200.50'" | sudo tee /etc/default/kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet
exit
kubectl get nodes -o wide
ls
cd addon/ingress/
ls
kubectl edit svc -n ingress-nginx ingress-nginx-controller
kubectl get ns
cd
ls
ls addon
ls
kubectl get po -A -o wide | grep k-control
kubectl describe nodes | grep Taint
kubectl get nodes
kubectl get rs
kubectl get po -A -o wide | grep k-control
cd /etc/kubernetes/manifests/
ls
cat etcd.yaml 
sudo cat etcd.yaml 
ls
sudo cat kube-apiserver.yaml 
cd
sudo -i
kubectl get pod -all
ls
cd addon/
la
ls
mkdir metrics-server
cd metrics-server/
ls
wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml
ls
vi components.yaml 
kubectl create -f components.yaml 
kubect get po -n kube-system
kubectl get po -n kube-system
kubectl top nodes
lscpu
cd
ls
kubectl get nodes
exit
kubectl get all,pvc,pv
git clone --single-branch --branch v1.6.7 https://github.com/rook/rook.git
ls
ls rook
mv rook ~/addon
ls
ls addon
cd rook/cluster/examples/kubernetes/ceph
cd rook
ls
cd addon/rook/cluster/examples/kubernetes/ceph
ls
kubectl create -f crds.yaml -f common.yaml -f operator.yaml
kubectl create -f cluster-test.yaml
kubectl -n rook-ceph get po
kubectl get no
kubectl -n rook-ceph get po
kubectl get no
kubectl delete -f crds.yaml -f common.yaml -f operator.yaml
kubectl delete -f cluster-test.yaml
kubectl create -f crds.yaml -f common.yaml -f operator.yaml
kubectl get ns
kubectl delete ns rook-ceph
kubectl create -f crds.yaml -f common.yaml -f operator.yaml
kubectl get ns
kubectl delete ns rook-ceph
kubectl get ns
kubectl delete ns rook-ceph
kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --show-all --ignore-not-found -n rook-ceph
kubectl get namespace rook-ceph -o yaml
ls
vi tmp.json 
kubectl proxy
vi tmp.json 
kubectl get ns
ls
vi tmp.json 
kubectl proxy
kubectl get all
exec bash
kubectl api-resources --namespaced=rook-ceph -o name
kubectl api-resources --rook-ceph=true -o name
kubectl api-resources rook-ceph=true -o name
kubectl api-resources rook-ceph -o name
ls
rm tmp.json 
ls
kubectl proxy &
yum install jq
sudo apt-get install jq
kubectl proxy &
