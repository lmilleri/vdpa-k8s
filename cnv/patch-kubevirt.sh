kubectl patch kubevirts -n kubevirt kubevirt --type=json -p='[{"op": "add", "path": "/spec/configuration",   "value": {
          "developerConfiguration": {
            "featureGates": ["NetworkBindingPlugins"]
          },
          "network": {
            "binding": {
                "vdpa": {
                    "sidecarImage": "quay.io/rh_ee_lmilleri/kubevirt/network-vdpa-binding:devel"
                }
            }
          }
        }}]'
