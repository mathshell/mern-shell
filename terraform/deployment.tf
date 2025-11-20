resource "kubernetes_deployment" "app_deployment" {
  metadata {
    name      = "mern-app"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
    labels = {
      app = "mern-app"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "mern-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "mern-app"
        }
      }

      spec {
        container {
          # CORRECTION ICI : Port 32000 et variable dynamique
          image = "localhost:32000/mern-app:${var.image_tag}"
          name  = "mern-app"
          
          # Force le téléchargement si vous réutilisez le tag 'latest'
          image_pull_policy = "Always" 

          port {
            container_port = 3000
          }

          env {
            name = "NODE_ENV"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.app_config.metadata[0].name
                key  = "NODE_ENV"
              }
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.app_secrets.metadata[0].name
            }
          }

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

          # ATTENTION : Vérifiez que votre code JS a bien une route GET /api/health
          # Sinon, supprimez ce bloc ou changez le path vers "/"
          liveness_probe {
            http_get {
              path = "/" 
              port = 3000
            }
            initial_delay_seconds = 30
            period_seconds        = 10
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app_service" {
  metadata {
    name      = "mern-service"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  spec {
    selector = {
      app = kubernetes_deployment.app_deployment.metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 3000
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "app_ingress" {
  metadata {
    name      = "mern-ingress"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    rule {
      host = "mern.local"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.app_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
