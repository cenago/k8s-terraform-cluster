variable "do_token" {
  description = "DigitalOcean API Token"
}

variable "region" {
  description = "The region to deploy the droplets"
  default     = "nyc1"
}

variable "size" {
  description = "The droplet size"
  default     = "s-1vcpu-2gb"
}

variable "image" {
  description = "The image to use for the droplets"
  default     = "ubuntu-22-04-x64"
}

variable "ssh_key_ids" {
  description = "SSH key IDs for accessing the droplets"
  type        = list(number)
  default     = []
}

variable "worker_count" {
  description = "Number of worker nodes for the cluster"
  default     = 2
}
