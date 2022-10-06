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

locals {
  namespace = "default"

  // E.g. from terraform
  azure_tenant_id       = var.azure.tenant_id
  azure_subscription_id = var.azure.subscription_id
  azure_application_id  = var.azure.application_id
  azure_client_secret   = var.azure.client_secret
  azure_resource_group  = var.azure.resource_group
  azure_location        = var.azure.location

  plugin_image         = "mcr.microsoft.com/oss/kubernetes-csi/blob-csi"
  plugin_image_version = "v1.16.0"
}

job "plugin-azure-blob-controller" {
  namespace   = local.namespace
  datacenters = ["dc1"]

  group "controller" {
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
        image = join(":", [local.plugin_image, local.plugin_image_version])

        mount {
          type     = "bind"
          target   = "/etc/kubernetes/azure.json"
          source   = "local/azure.json"
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
        type      = "controller"
        mount_dir = "/csi"
      }

      resources {
        cpu        = 100
        memory     = 50
        memory_max = 250
      }
    }
  }
}