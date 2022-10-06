job "csi-create-volume" {
  
  datacenters = ["dc1"]
  type = "batch"
  
  parameterized {
    meta_optional = ["NOMAD_ADDRESS","NOMAD_TOKEN","NOMAD_NAMESPACE"]
    meta_required = []
    payload       = "required"
  }

  group "create" {
    
    ephemeral_disk {
      migrate = false
      sticky  = false
      size    = 10
    }

    task "nomad" {
      driver = "docker" // or use raw_exec

      dispatch_payload {
        file = "volume.hcl"
      }
      
      env {
        NOMAD_ADDR = "http://${attr.unique.network.ip-address}:4646"
        NOMAD_CLI_FORCE_COLOR = "true"
      }

      config {
        image = "kdsda/nomad:scratch-1.4.0"
        args  = [
          "volume", "create",
          "-address=${NOMAD_META_NOMAD_ADDRESS}",
          "-namespace=${NOMAD_META_NOMAD_NAMESPACE}",
          "-token=${NOMAD_META_NOMAD_TOKEN}",
          "${NOMAD_TASK_DIR}/volume.hcl"
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
