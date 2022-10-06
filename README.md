# NOMAD-CSI-DEMO

Example use of CSI-volumes with Nomad scheduler
Note that Nomad does NOT need to run on Azure to use the Azure csi-drivers

## azure/terraform/

  * [Terraform Code](azure/terraform/)

Create Resource Group and service account for testing/using csi-volumes with Nomad

```bash
# Create Azure resources
terraform init
terraform apply -auto-approve

# Print credentials for csi-plugin
terraform output info 
```

## Plugin: azure-blob-csi

* [Nomad Jobfiles](azure/nomad-azure-blob-csi/)
* [Official Documentation](https://github.com/kubernetes-sigs/blob-csi-driver)

## Plugin: azure-disk-csi (NOT WORKING)

* [Nomad Jobfiles](azure/nomad-azure-disk-csi/)
* [Official Documentation](https://github.com/kubernetes-sigs/azurefile-csi-driver)
