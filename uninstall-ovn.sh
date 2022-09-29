#!/usr/bin/env bash

pushd /home/kube/go/src/ovn-kubernetes/dist/images

pushd ../yaml


kubectl delete -f ovnkube-node.yaml
kubectl delete -f ovnkube-master.yaml
kubectl delete -f ovnkube-db.yaml
kubectl delete -f ovn-setup.yaml

# just trying ...
kubectl delete -f k8s.ovn.org_egressips.yaml
kubectl delete -f k8s.ovn.org_egressfirewalls.yaml

popd
