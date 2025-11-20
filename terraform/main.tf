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

# terraform/main.tf (Extrait corrigé)

resource "kubernetes_secret" "app_secrets" {
  metadata {
    name      = "app-secrets"
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }

  data = {
    # --- CORRECTION ICI ---
    # On utilise le protocole 'mongodb://'
    # On pointe vers le service 'mongo-service' sur le port '27017'
    # Le nom de la base de données est 'mern-db' (créée automatiquement)
    DATABASE_URL = "mongodb://mongo-service:27017/mern-db"
    
    # Vos autres secrets
    JWT_SECRET   = "votre-super-secret-jwt"
    NEXTAUTH_URL = "http://mern.local"
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
# terraform/providers.tf

# Configuration pour utiliser le cluster Kind
provider "kubernetes" {
  # Terraform utilisera le kubeconfig généré par Kind
  config_context = "kind-mern-cluster" 
}
