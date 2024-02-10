module "cloudflared_tunnel_dns" {
  source = "../terraform-modules/cloudflared-tunnel-dns"

  application          = local.application
  environment          = local.environment
  deployment_url       = local.kubernetes_dashboard_url
  CLOUDFLARE_TUNNEL_ID = cloudflare_tunnel.this.id
}
