resource "kubernetes_persistent_volume" "mariadb_pv" {
  metadata {
    name = "mariadb-pv"
  }

  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      host_path {
        path = "/mnt/data/mariadb"
      }
    }
  }
}
