locals {

  argocd = merge(
    local.helm_defaults,
    {
      name          = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-cd")].name
      chart         = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-cd")].name
      repository    = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-cd")].repository
      chart_version = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-cd")].version
    }
  )
}

resource "kubernetes_namespace" "argo-cd" {

  count = local.addon_flag_sdlc

  metadata {
    name = "argo-cd"
  }
  depends_on = [module.eks, data.http.wait_for_cluster]
}

resource "helm_release" "argo-cd" {

  count = local.addon_flag_sdlc

  repository            = local.argocd["repository"]
  name                  = local.argocd["name"]
  chart                 = local.argocd["chart"]
  version               = local.argocd["chart_version"]
  timeout               = local.argocd["timeout"]
  force_update          = local.argocd["force_update"]
  recreate_pods         = local.argocd["recreate_pods"]
  wait                  = local.argocd["wait"]
  atomic                = local.argocd["atomic"]
  cleanup_on_fail       = local.argocd["cleanup_on_fail"]
  dependency_update     = local.argocd["dependency_update"]
  disable_crd_hooks     = local.argocd["disable_crd_hooks"]
  disable_webhooks      = local.argocd["disable_webhooks"]
  render_subchart_notes = local.argocd["render_subchart_notes"]
  replace               = local.argocd["replace"]
  reset_values          = local.argocd["reset_values"]
  reuse_values          = local.argocd["reuse_values"]
  skip_crds             = local.argocd["skip_crds"]
  verify                = local.argocd["verify"]
  namespace             = "argo-cd"

  values = [
    file("${path.module}/helm/argo-cd/argo-cd-values.yaml")
  ]

  depends_on = [module.eks, kubernetes_namespace.argo-cd, data.http.wait_for_cluster]
}
