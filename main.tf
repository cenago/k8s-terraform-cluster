terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# Droplet for the Kubernetes Master Node
resource "digitalocean_droplet" "k8s_master" {
  count   = 1
  name    = "k8s-master-${count.index}"
  region  = var.region
  size    = var.size
  image   = var.image
  ssh_keys = var.ssh_key_ids

  # Optional: User data script to install Kubernetes components
  user_data = <<-EOF
              #!/bin/bash
              set -e
              apt-get update
              apt-get install -y docker.io
              curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
              echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
              apt-get update
              apt-get install -y kubelet kubeadm kubectl
              apt-mark hold kubelet kubeadm kubectl

              # Initialize Kubernetes
              kubeadm init --pod-network-cidr=192.168.0.0/16

              # Set kubectl for the root user
              mkdir -p $HOME/.kube
              cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
              chown $(id -u):$(id -g) $HOME/.kube/config
              EOF
}

# Droplets for Kubernetes Worker Nodes
resource "digitalocean_droplet" "k8s_workers" {
  count   = var.worker_count
  name    = "k8s-worker-${count.index}"
  region  = var.region
  size    = var.size
  image   = var.image
  ssh_keys = var.ssh_key_ids

  # Optional: User data script to install Kubernetes components
  user_data = <<-EOF
              #!/bin/bash
              set -e
              apt-get update
              apt-get install -y docker.io
              curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
              echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list
              apt-get update
              apt-get install -y kubelet kubeadm kubectl
              apt-mark hold kubelet kubeadm kubectl

              # Join the Kubernetes cluster
              kubeadm join ${digitalocean_droplet.k8s_master[0].ipv4_address}:6443 --token <YOUR_TOKEN> --discovery-token-ca-cert-hash sha256:<YOUR_HASH>
              EOF
}

