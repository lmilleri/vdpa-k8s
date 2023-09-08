#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    echo "usage: $0 <TAG>"
    exit -1    
fi

sed -i "s/ovn-daemonset-f.*/ovn-daemonset-f:$1/g" patch-ovn-image.yaml

oc scale --replicas=0 deployment.apps/cluster-version-operator -n openshift-cluster-version
oc scale --replicas=0 deployment.apps/network-operator -n openshift-network-operator
oc patch -p "$(cat patch-ovn-image.yaml)" deploy network-operator -n openshift-network-operator
oc scale --replicas=1 deployment.apps/network-operator -n openshift-network-operator


watch -n 15 "oc get pods -A | grep ovn"
