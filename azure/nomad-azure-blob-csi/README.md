# nomad-csi-demo

Example use of Azure CSI-blob with Nomad scheduler

## azure/nomad-azure-blob-csi/

https://github.com/kubernetes-sigs/blob-csi-driver

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
nomad plugin status -verbose az-blob

# Create an azure disk
nomad volume status
nomad volume create volume.hcl
nomad volume status -json vol-1

# Start demo-job using the disk
nomad job plan example-job.nomad.hcl
```
