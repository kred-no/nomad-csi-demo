job "csi-demo" {
  
  datacenters = ["dc1"]

  group "demo" {

    ephemeral_disk {
      migrate = false
      sticky  = false
      size    = 50
    }

    volume "csi_volume" {
      type            = "csi"
      source          = "vol-1"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
      per_alloc       = false //Requires [n] for volume names ..
    }
    
    task "nginx" {
      driver = "docker"
      
      config {
        image = "nginx:alpine"
      }

      resources {
        cpu        = 100
        memory     = 50
        memory_max = 100
      }

      volume_mount {
        volume      = "csi_volume"
        destination = "/alloc/azure"
      }


      logs {
        max_files     = 5
        max_file_size = 5
      }
    }
  }
}
