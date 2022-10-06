job "csi-delete-volume" {
  
  datacenters = ["dc1"]
  type = "batch"
  
  parameterized {
    meta_optional = ["NOMAD_TOKEN","NOMAD_NAMESPACE"]
    meta_required = ["volume_id"]
    payload       = "forbidden"
  }

  group "delete" {
    
    ephemeral_disk {
      migrate = false
      sticky  = false
      size    = 10
    }

    task "nomad" {
      driver = "docker" // or use raw_exec

      env {
        NOMAD_ADDR = "http://${attr.unique.network.ip-address}:4646"
        NOMAD_CLI_FORCE_COLOR = "true"
      }

      config {
        image = "kdsda/nomad:scratch-1.4.0"
        args  = [
          "volume", "delete",
          "-namespace","${NOMAD_META_NOMAD_NAMESPACE}",
          "-token","${NOMAD_META_NOMAD_TOKEN}",
          "${NOMAD_META_volume_id}"
        ]
      }

      resources {
        cpu        = 25
        memory     = 25
        memory_max = 100
      }

      logs {
        max_files     = 3
        max_file_size = 3
      }
    }
  }
}
