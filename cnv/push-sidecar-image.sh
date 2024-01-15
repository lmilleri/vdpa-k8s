docker pull localhost:5000/kubevirt/network-vdpa-binding:devel
docker tag localhost:5000/kubevirt/network-vdpa-binding:devel quay.io/rh_ee_lmilleri/kubevirt/network-vdpa-binding:devel
docker push quay.io/rh_ee_lmilleri/kubevirt/network-vdpa-binding:devel
