#!/usr/bin/env bash

sudo systemctl stop kubelet
sudo systemctl disable kubelet

sudo dnf remove -y kubelet kubeadm kubectl

