variable "application" {
  type = string
}

variable "environment" {
  type = string
}

variable "deployment_url" {
  type = string
}

variable "CLOUDFLARE_TUNNEL_ID" {
  type = string
  sensitive = true
}
