resource "kubernetes_namespace" "nginx_ingress" {
  metadata {
    name = "nginx"
    labels = {
      name = "nginx"
    }
  }
}

resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress-controller"
  namespace        = kubernetes_namespace.nginx_ingress.metadata[0].name
  create_namespace = false

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  set {
    name  = "fullnameOverride"
    value = local.nginx_fullname_override
  }
  set {
    name  = "controller.admissionWebhooks.enabled"
    value = "false"
  }
  set {
    name  = "controller.service.type"
    value = "ClusterIP"
  }
  set {
    name  = "controller.config.ssl-redirect"
    value = "false"
  }
  set {
    name  = "controller.config.use-forwarded-headers"
    value = "true"
  }
  set {
    name  = "controller.config.proxy-body-size"
    value = "100m"
  }
  set {
    name  = "controller.resources.requests.cpu"
    value = "1000m"
  }
  set {
    name  = "controller.resources.requests.memory"
    value = "1024Mi"
  }
  set {
    name  = "controller.replicaCount"
    value = "2"
  }
  set {
    name  = "defaultBackend.enabled"
    value = "true"
  }
  set {
    name  = "controller.config.http-snippet"
    value = <<-EOT
      proxy_intercept_errors on;
      error_page 503 = @custom_error_upstream;
    EOT
  }
  set {
    name  = "controller.config.server-snippet"
    value = <<-EOT
      location @custom_error_upstream {
        proxy_pass https://opensourcesanjose.org:443;
        proxy_set_header Host opensourcesanjose.org;
        proxy_pass_request_headers on;
        proxy_ssl_server_name on;
      }
    EOT
  }
  set {
    name  = "controller.config.enable-access-log-for-default-backend"
    value = "true"
  }
  # set {
  #   name  = "controller.config.error-log-level"
  #   value = "debug"
  # }

  depends_on = [kubernetes_namespace.nginx_ingress]
  lifecycle {
    ignore_changes = [metadata]
  }
}
