cd kubevirt/
make && make cluster-up && make cluster-sync
cd ..
./patch-kubevirt.sh
# ./chmod-vdpa.sh
./push-sidecar-image.sh
kubectl create -f nad.yaml
