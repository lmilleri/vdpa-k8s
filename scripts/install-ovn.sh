#!/usr/bin/env bash

pushd /home/kube/go/src/ovn-kubernetes/dist/images

#OVN_IMAGE=quay.io/amorenoz/ovnkube-node
#OVN_IMAGE=docker.io/ovnkube/ovn-daemonset-u:latest
#OVN_IMAGE=quay.io/rh_ee_lmilleri/ovn-daemonset-f:latest
OVN_IMAGE=quay.io/rh_ee_lmilleri/ovn-daemonset-f:vdpa
 ./daemonset.sh --image=$OVN_IMAGE --net-cidr=192.168.0.0/16 --svc-cidr=10.96.0.0/12 --gateway-mode="local" --k8s-apiserver=https://10.19.153.1:6443
#./daemonset.sh --image=$OVN_IMAGE --net-cidr=10.244.0.0/16 --svc-cidr=10.96.0.0/12 --gateway-mode="local" --k8s-apiserver=https://10.19.153.1:6443


pushd ../yaml

#kubectl apply -f k8s.ovn.org_egressfirewalls.yaml
#kubectl apply -f k8s.ovn.org_egressips.yaml

kubectl create -f ovn-setup.yaml
kubectl create -f ovnkube-db.yaml
kubectl create -f ovnkube-master.yaml
kubectl create -f ovnkube-node.yaml

popd
