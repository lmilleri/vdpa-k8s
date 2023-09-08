oc apply -f https://github.com/nmstate/kubernetes-nmstate/releases/download/v0.80.0/nmstate.io_nmstates.yaml
oc apply -f https://github.com/nmstate/kubernetes-nmstate/releases/download/v0.80.0/namespace.yaml
oc apply -f https://github.com/nmstate/kubernetes-nmstate/releases/download/v0.80.0/service_account.yaml
oc apply -f https://github.com/nmstate/kubernetes-nmstate/releases/download/v0.80.0/role.yaml
oc apply -f https://github.com/nmstate/kubernetes-nmstate/releases/download/v0.80.0/role_binding.yaml
oc apply -f https://github.com/nmstate/kubernetes-nmstate/releases/download/v0.80.0/operator.yaml

cat <<EOF | kubectl create -f -
apiVersion: nmstate.io/v1
kind: NMState
metadata:
  name: nmstate
EOF
