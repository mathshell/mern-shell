# terraform/mongo.tf

# --- Déploiement de la Base de Données (MongoDB) ---
resource "kubernetes_deployment" "mongo_deployment" {
  metadata {
    name      = "mongo"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
    labels = {
      app = "mongo"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mongo"
      }
    }
    template {
      metadata {
        labels = {
          app = "mongo"
        }
      }
      spec {
        container {
          image = "mongo:6.0" # Version stable de MongoDB
          name  = "mongo"
          
          port {
            container_port = 27017
          }
          
          # (Optionnel) Limites de ressources pour éviter de surcharger le cluster
          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

# --- Service pour exposer MongoDB aux autres Pods ---
resource "kubernetes_service" "mongo_service" {
  metadata {
    name      = "mongo-service"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }
  spec {
    selector = {
      app = kubernetes_deployment.mongo_deployment.metadata[0].labels.app
    }
    port {
      port        = 27017
      target_port = 27017
    }
    type = "ClusterIP" # Type par défaut, accessible uniquement en interne
  }
}
