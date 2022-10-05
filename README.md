# nomad-csi-demo

Example use of CSI-volumes with Nomad scheduler

## azure/terraform/

Create Resource Group and service account for csi-volumes

```bash
# Create Azure resources
terraform init
terraform apply -auto-approve

# Print credentials for csi-plugin
terraform output info 
```

## azure/nomad/

* Nomad volume definition

* Nomad Jobs:
    * azure-csi-controller 
    * azure-csi-nodes
    * job using csi-volume

```bash
# Set your target Nomad cluster
source nomad.env

# Create azure csi-jobs
nomad job run csi-azure-controller.nomad.hcl
nomad job run csi-azure-node.nomad.hcl

# Check jobs/plugin status
nomad job status
nomad plugin status -verbose az-disk0

# Create an azure disk
nomad volume status
nomad volume create volume.hcl
nomad volume status -json azure-disk0

# Start demo-job using the disk
nomad job plan csi-demo.nomad.hcl
```

#### nomad job plan output (demo)

```plain
Task Group "demo" (failed to place 1 allocation):
    * Class "standard": 1 nodes excluded by filter
    * Constraint "did not meet topology requirement": 1 nodes excluded by filter
```

#### volume status output (azure-disk0)
```json
"RequestedTopologies": {
  "Preferred": [{
    "Segments": {
      "topology.disk.csi.azure.com/zone": "norwayeast"
    }
  }],
  "Required": [{
    "Segments": {
      "topology.disk.csi.azure.com/zone": ""
    }
  }]
},
"Topologies": [
  null, {
  "Segments": {
  "topology.disk.csi.azure.com/zone": ""
  }
}]
```
