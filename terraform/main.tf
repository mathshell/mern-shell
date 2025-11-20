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

# Déclaration de la variable pour le Tag Docker
variable "image_tag" {
  description = "Le tag de l'image Docker à déployer"
  type        = string
  default     = "latest" 
}

provider "kubernetes" {
  # Jenkins cherchera ici (assurez-vous d'avoir fait l'étape 'cp config' précédente)
  config_path = "/var/lib/jenkins/.kube/config" 
}

provider "helm" {
  kubernetes {
    config_path = "/var/lib/jenkins/.kube/config"
  }
}

resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = "mern-app"
  }
}

resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "app-secrets"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  data = {
    # Mettez ici les vraies infos de votre DB ou laissez temporaire
    DATABASE_URL = "mysql://user:pass@mysql-service:3306/ecommerce"
    JWT_SECRET   = "your-jwt-secret"
    NEXTAUTH_URL = "http://mern.local" # Mieux vaut mettre l'URL finale
  }
}

resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  data = {
    # CORRECTION : Ajout de la clé requise par deployment.tf
    NODE_ENV = "production" 
    
    "config.js" = <<-EOT
      module.exports = {
        env: {
          CUSTOM_KEY: 'custom-value',
        },
      }
    EOT
  }
}
