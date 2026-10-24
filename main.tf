terraform {
  required_version = ">= 1.5.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
}

# Configure your DigitalOcean Token (passed via environment variable: export TF_VAR_do_token="your_token")
variable "do_token" {
  type      = string
  sensitive = true
}

provider "digitalocean" {
  token = var.do_token
}

# 1. Provision the DigitalOcean Kubernetes Cluster
resource "digitalocean_kubernetes_cluster" "primary" {
  name    = "srisaiela-cluster"
  region  = "blr1"
  version = "1.31.2-do.0" # Use a stable current DO k8s version

  node_pool {
    name       = "autoscale-pool"
    size       = "s-2vcpu-4gb"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 3
  }
}

# Configure Kubernetes and Helm providers using the created cluster credentials
provider "kubernetes" {
  host  = digitalocean_kubernetes_cluster.primary.endpoint
  token = digitalocean_kubernetes_cluster.primary.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = digitalocean_kubernetes_cluster.primary.endpoint
    token = digitalocean_kubernetes_cluster.primary.kube_config[0].token
    cluster_ca_certificate = base64decode(
      digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
    )
  }
}