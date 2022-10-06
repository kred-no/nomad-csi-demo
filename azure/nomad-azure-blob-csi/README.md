# nomad-csi-demo

Example use of Azure CSI-blob with Nomad scheduler

## azure/nomad-azure-blob-csi/

https://github.com/kubernetes-sigs/blob-csi-driver

* Nomad volume definition

* Nomad Jobs:
    * azure-csi-controller 
    * azure-csi-nodes
    * demo-job using csi-volume
    * Optional batch jobs for dispatching create/delete volume commands.

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

# OPTIONAL:
# Create/delete disk using parametrized batch-jobs (i.e. "allow" using UI)
# Only for testing; token in plan text, etc..
nomad job run volume-create-job.nomad.hcl
nomad job run volume-delete-job.nomad.hcl

# Start demo-job using the disk
nomad job plan csi-job.nomad.hcl
nomad job run csi-job.nomad.hcl

# Delete volume
nomad job stop -purge csi-demo
nomad volume delete vol-1

# Cleanup
nomad job stop -purge csi-create-volume
nomad job stop -purge csi-delete-volume
nomad job stop -purge plugin-azure-blob-node
nomad job stop -purge plugin-azure-blob-controller
```
