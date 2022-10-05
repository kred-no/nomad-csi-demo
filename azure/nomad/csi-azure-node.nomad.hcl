variable "credentials" {
  type = object({
    tenant_id       = string
    subscription_id = string
    application_id  = string
    client_secret   = string
  })
}

locals {
  // E.g. from terraform
  azure_tenant_id      = var.azure.tenant_id
  azure_subscriptionId = var.azure.subscription_id
  azure_application_id = var.azure.application_id
  azure_client_secret  = var.azure.client_secret

  plugin_image         = "mcr.microsoft.com/oss/kubernetes-csi/azuredisk-csi"
  plugin_image_version = "v1.12.0" //v1.13.0 fails on nodes (not controller)
}

job "plugin-azure-disk-nodes" {
  namespace   = "kds"
  datacenters = ["dc1"]

  type = "system"

  group "nodes" {
    task "plugin" {
      driver = "docker"

      template {
        change_mode = "noop"
        destination = "local/azure.json"

        data = <<-EOH
        {
          "cloud": "AzurePublicCloud",
          "tenantId": "${local.azure_tenant_id}",
          "subscriptionId": "${local.azure_subscription_id}",
          "aadClientId": "${local.azure_application_id}",
          "aadClientSecret": "${local.azure_client_secret}",
          "resourceGroup": "nomad-csi",
          "location": "norwayeast",
        }
        EOH
      }

      env {
        AZURE_CREDENTIAL_FILE = "/etc/kubernetes/azure.json"
      }

      config {
        image      = join(":",[local.plugin_image,local.plugin_image_version])
        privileged = true
        
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
        id        = "az-disk0"
        type      = "node"
        mount_dir = "/csi"
      }

      resources {
        cpu        = 100
        memory     = 75
        memory_max = 300
      }
    }
  }
}