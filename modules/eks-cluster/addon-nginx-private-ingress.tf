resource "helm_release" "nginx-private-ingress" {

  count = local.addon_flag_networking

  name       = "nginx-private-ingress"
  chart      = local.helm_dependencies[index(local.helm_dependencies.*.name, "ingress-nginx")].name
  repository = local.helm_dependencies[index(local.helm_dependencies.*.name, "ingress-nginx")].repository
  version    = local.helm_dependencies[index(local.helm_dependencies.*.name, "ingress-nginx")].version
  namespace  = "kube-system"
  atomic     = true

  values = [
    file("${path.module}/helm/nginx-ingress/nginx-private-ingress-values.yaml")
  ]

  set {
    name  = "controller.service.internal.annotations.service\\.beta\\.kubernetes\\.io/aws-loadbalancer-name"
    value = "${var.cluster_name}-internal-ingress-nlb"
    type  = "auto"
  }

  depends_on = [
    module.eks,
    data.http.wait_for_cluster,
    resource.kubernetes_config_map.custom_error_pages
  ]

}

