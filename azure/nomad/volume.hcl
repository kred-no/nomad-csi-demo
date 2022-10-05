# Run: nomad volume create volume.hcl
id        = "azure-disk0"
name      = "azure-disk0"

type      = "csi"
plugin_id = "az-disk0"

capacity_min = "5GiB"
capacity_max = "5GiB"

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}

mount_options {
  fs_type     = "ext4"
  mount_flags = ["noatime", "rw"]
}

topology_request {
  required {
    topology {
      segments {
        "topology.disk.csi.azure.com/zone" = ""
      }
    }
  }

  preferred {
    topology {
      segments {
        "topology.disk.csi.azure.com/zone" = "norwayeast"
      }
    }
  }
}
