variable "azure" {
  type = object({
    tenant_id       = string
    subscription_id = string
    application_id  = string
    client_secret   = string
    resource_group  = string
    location        = string
  })
}

variable "plugin_version" {
  type    = string
  default = "v1.16.0"
}

variable "namespace" {
  type    = string
  default = "default"
}

locals {
  namespace = var.namespace
  
  // E.g. from terraform
  azure_tenant_id       = var.azure.tenant_id
  azure_subscription_id = var.azure.subscription_id
  azure_application_id  = var.azure.application_id
  azure_client_secret   = var.azure.client_secret
  azure_resource_group  = var.azure.resource_group
  azure_location        = var.azure.location

  plugin_image         = "mcr.microsoft.com/oss/kubernetes-csi/blob-csi"
  plugin_image_version = var.plugin_version
}

//////////////////////////////////
// NOMAD JOBSPEC
//////////////////////////////////

job "plugin-azure-blob-nodes" {
  namespace   = local.namespace
  datacenters = ["dc1"]

  type = "system"

  group "nodes" {

    ephemeral_disk {
      migrate = false
      sticky  = false
      size    = 50
    }
    
    task "plugin" {
      driver = "docker"

      template {
        change_mode = "noop"
        destination = "/local/azure.json"
        
        data = jsonencode({
          cloud           = "AzurePublicCloud",
          tenantId        = local.azure_tenant_id
          subscriptionId  = local.azure_subscription_id
          aadClientId     = local.azure_application_id
          aadClientSecret = local.azure_client_secret
          resourceGroup   = local.azure_resource_group
          location        = local.azure_location
        })
      }

      env {
        AZURE_CREDENTIAL_FILE = "/etc/kubernetes/azure.json"
      }

      config {
        image      = join(":",[local.plugin_image,local.plugin_image_version])
        privileged = true
        
        mount {
          type     = "bind"
          source   = "local/azure.json"
          target   = "/etc/kubernetes/azure.json"
          readonly = true
        }

        args = [
          "--nodeid=${attr.unique.hostname}",
          "--endpoint=unix:///csi/csi.sock",
          "--logtostderr",
          "--v=5",
        ]
      }

      csi_plugin {
        id        = "az-blob"
        type      = "node"
        mount_dir = "/csi"
      }

      resources {
        cpu        = 100
        memory     = 50
        memory_max = 250
      }

      logs {
        max_files     = 5
        max_file_size = 5
      }
    }
  }
}