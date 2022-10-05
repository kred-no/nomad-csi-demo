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

## Logs

#### nomad job plan output (demo)

```log
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

#### node cni-job failing on v1.13.0+

```log
I1005 11:28:49.416752       1 utils.go:77] GRPC call: /csi.v1.Identity/GetPluginInfo
I1005 11:28:49.416770       1 utils.go:78] GRPC request: {}
I1005 11:28:49.418230       1 utils.go:84] GRPC response: {"name":"disk.csi.azure.com","vendor_version":"v1.23.0"}
I1005 11:28:49.420323       1 utils.go:77] GRPC call: /csi.v1.Identity/GetPluginCapabilities
I1005 11:28:49.420378       1 utils.go:78] GRPC request: {}
I1005 11:28:49.420459       1 utils.go:84] GRPC response: {"capabilities":[{"Type":{"Service":{"type":1}}},{"Type":{"Service":{"type":2}}},{"Type":{"VolumeExpansion":{"type":2}}},{"Type":{"VolumeExpansion":{"type":1}}}]}
I1005 11:28:49.427439       1 utils.go:77] GRPC call: /csi.v1.Node/NodeGetInfo
I1005 11:28:49.427515       1 utils.go:78] GRPC request: {}
I1005 11:28:50.000305       1 util.go:123] Send.sendRequest got response with ContentLength 227, StatusCode 404 and responseBody length 227
I1005 11:28:50.000346       1 azure_vmclient.go:133] Received error in vm.get.request: resourceID: /subscriptions/xxxxxxx/resourceGroups/nomad-csi/providers/Microsoft.Compute/virtualMachines/74281f1a0b37, error: Retriable: false, RetryAfter: 0s, HTTPStatusCode: 404, RawError: {"error":{"code":"ResourceNotFound","message":"The Resource 'Microsoft.Compute/virtualMachines/74281f1a0b37' under resource group 'nomad-csi' was not found. For more details please go to https://aka.ms/ARMResourceNotFoundFix"}}
I1005 11:28:50.000790       1 azure_wrap.go:210] Virtual machine "74281f1a0b37" not found
W1005 11:28:50.000836       1 azure_wrap.go:77] Unable to find node 74281f1a0b37: instance not found
W1005 11:28:50.000851       1 nodeserver.go:339] get zone(NOMAD-VM-NAME) failed with: instance not found, fall back to get zone from node labels
E1005 11:28:50.000868       1 utils.go:82] GRPC error: rpc error: code = Internal desc = getNodeInfoFromLabels on node(NOMAD-VM-NAME) failed with kubeClient is nil
```