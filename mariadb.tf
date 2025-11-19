# Persistent Volume Claim (PVC) - Pastikan ini hanya ada satu kali di seluruh file .tf Anda
resource "kubernetes_persistent_volume_claim" "mariadb" {
  metadata {
    name = "mariadb-pvc"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi" # Mengklaim PV 5Gi Anda
      }
    }
    storage_class_name = "standard" # Pastikan StorageClass ini tersedia
  }
}

# Deployment (MariaDB)
resource "kubernetes_deployment" "mariadb" {
  metadata {
    name = "mariadb"
    labels = {
      app = "mariadb"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mariadb"
      }
    }
    template {
      metadata {
        labels = {
          app = "mariadb"
        }
      }
      spec {
        container {
          name  = "mariadb"
          image = "mariadb:latest" 
          port {
            container_port = 3306
          }
          
          # 🛑 KOREKSI SINTAKSIS PENTING PADA BAGIAN ENV (TANPA {})
          env {
            name = "MARIADB_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mariadb-secret"
                key  = "mariadb-password"
              }
            }
          }
          # Contoh penambahan environment variable yang benar (Tanpa tanda kurung () atau {})
          env {
            name  = "MARIADB_DATABASE"
            value = "sofiah" 
          }
          # --------------------------------------------------------

          volume_mount {
            name      = "mariadb-storage"
            mount_path = "/var/lib/mysql"
          }
        }
        volume {
          name = "mariadb-storage"
          persistent_volume_claim {
            claim_name = "mariadb-pvc"
          }
        }
      }
    }
  }
}

# Service (MariaDB)
resource "kubernetes_service" "mariadb" {
  metadata {
    name = "mariadb-service"
  }
  spec {
    selector = {
      app = "mariadb"
    }
    port {
      port        = 3306
      target_port = 3306
      node_port   = 30036 # Tentukan NodePort untuk akses eksternal
    }
    type = "NodePort"
  }
}
