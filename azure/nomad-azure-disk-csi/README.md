# nomad-csi-demo (NOT WORKING)

Example use of Azure CSI-disk with Nomad scheduler

## azure/nomad-azure-disk-csi/

See https://github.com/kubernetes-sigs/azurefile-csi-driver

* Nomad volume definition

* Nomad Jobs:
    * azure-csi-controller 
    * azure-csi-nodes
    * job using csi-volume

```bash
# Set your target Nomad cluster
source nomad.env

# Create azure csi-jobs
nomad job run csi-controller.nomad.hcl
nomad job run csi-node.nomad.hcl

# Check jobs/plugin status
nomad job status
nomad plugin status -verbose az-disk

# Create an azure disk
nomad volume status
nomad volume create volume.hcl
nomad volume status -json azure-disk

# Start demo-job using the disk
nomad job plan csi-demo.nomad.hcl
```

