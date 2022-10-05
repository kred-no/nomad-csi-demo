job "csi-demo" {
  datacenters = ["dc1"]

  group "web" {

    ephemeral_disk {
      size = 100
    }

    volume "azure_disk" {
      type            = "csi"
      source          = "azure-disk0"
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
        cpu    = 75
        memory = 75
      }

      volume_mount {
        volume      = "azure_disk"
        destination = "/alloc/azure"
      }


      logs {
        max_files     = 5
        max_file_size = 10
      }
    }
  }
}
