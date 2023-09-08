#!/usr/bin/env bash

oc patch -p "$(cat override-cno-image-patch.yaml)" deploy network-operator -n openshift-network-operator

#oc scale --replicas=0 deployment.apps/cluster-version-operator -n openshift-cluster-version
#oc scale --replicas=0 deployment.apps/network-operator -n openshift-network-operator
#oc patch -p "$(cat patch-ovn-image.yaml)" deploy network-operator -n openshift-network-operator
#oc scale --replicas=1 deployment.apps/network-operator -n openshift-network-operator
#watch -n 15 "oc get pods -A | grep ovn"
