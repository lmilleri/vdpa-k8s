#!/usr/bin/env bash

echo "echo 1 > /proc/sys/net/ipv4/ip_forward" | sudo sh

sudo rm -rf /etc/cni/net.d/

sudo kubeadm init --token-ttl 0 --pod-network-cidr=10.244.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl label nodes virtlab712.virt.lab.eng.bos.redhat.com node-role.kubernetes.io/master=
kubectl label nodes virtlab712.virt.lab.eng.bos.redhat.com node-role.kubernetes.io/worker=
kubectl label nodes virtlab712.virt.lab.eng.bos.redhat.com feature.node.kubernetes.io/network-sriov.capable=true
