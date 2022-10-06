# Run: nomad volume create volume.hcl
id        = "vol-1"
name      = "volume-1"

type      = "csi"
plugin_id = "az-disk"

capacity_min = "5GiB"
capacity_max = "5GiB"

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}

mount_options {
  fs_type     = "ext4"
}
