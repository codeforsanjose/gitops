resource "kubernetes_namespace" "this" {
  metadata {
    name = "${local.application}-${local.environment}"
    labels = {
      name = "${local.application}-${local.environment}"
    }
  }
}

module "doppler" {
  source = "../../../../../terraform-modules/eks-app-doppler-integration"

  namespace         = kubernetes_namespace.this.metadata[0].name
  application       = local.application
  environment       = local.environment
  aws_region        = local.aws_region
  auto_sync_doppler = local.auto_sync_doppler
}

module "cloudflared_tunnel_dns" {
  source = "../../../../../terraform-modules/cloudflared-tunnel-dns"

  application    = local.application
  environment    = local.environment
  deployment_url = local.deployment_url
  CLOUDFLARE_TUNNEL_ID = var.CLOUDFLARE_TUNNEL_ID
}
