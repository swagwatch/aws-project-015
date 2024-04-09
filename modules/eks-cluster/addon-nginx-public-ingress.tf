resource "helm_release" "nginx-public-ingress" {

  count = local.addon_flag_networking

  name       = "nginx-public-ingress"
  namespace  = "kube-system"
  chart      = local.helm_dependencies[index(local.helm_dependencies.*.name, "ingress-nginx")].name
  repository = local.helm_dependencies[index(local.helm_dependencies.*.name, "ingress-nginx")].repository
  version    = local.helm_dependencies[index(local.helm_dependencies.*.name, "ingress-nginx")].version
  atomic     = true

  values = [
    file("${path.module}/helm/nginx-ingress/nginx-public-ingress-values.yaml")
  ]

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
    value = var.public_ingress_cert_arn
    type  = "auto"
  }

  set {
    name  = "controller.metrics.enabled"
    value = true
    type  = "auto"
  }

  depends_on = [
    module.eks,
    data.http.wait_for_cluster,
    resource.kubernetes_config_map.custom_error_pages,
    resource.helm_release.nginx-private-ingress,
    resource.helm_release.aws_load_balancer_controller
  ]
}
