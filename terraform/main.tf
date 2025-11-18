terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.30.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Namespace pour l'application
resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = "ecommerce-app"
  }
}

# Secret pour les variables d'environnement
resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "app-secrets"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  data = {
    DATABASE_URL = "mysql://user:pass@mysql-service:3306/ecommerce"
    JWT_SECRET   = "your-jwt-secret"
    NEXTAUTH_URL = "https://your-domain.com"
  }
}

# ConfigMap pour la configuration
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  data = {
    "config.js" = <<-EOT
      module.exports = {
        env: {
          CUSTOM_KEY: 'custom-value',
        },
      }
    EOT
  }
}
