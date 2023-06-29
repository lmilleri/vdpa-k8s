#!/usr/bin/env bash

sudo kubeadm reset -f
sudo rm -rf /etc/cni/net.d/*
rm $HOME/.kube/config
