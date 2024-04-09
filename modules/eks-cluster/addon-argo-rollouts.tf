locals {

  argorollouts = merge(
    local.helm_defaults,
    {
      name          = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-rollouts")].name
      chart         = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-rollouts")].name
      repository    = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-rollouts")].repository
      chart_version = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-rollouts")].version
    }
  )
}

resource "kubernetes_namespace" "argo-rollouts" {

  count = local.addon_flag_sdlc

  metadata {
    name = "argo-rollouts"
  }
  depends_on = [module.eks, data.http.wait_for_cluster]
}

resource "helm_release" "argo-rollouts" {

  count = local.addon_flag_sdlc

  repository            = local.argorollouts["repository"]
  name                  = local.argorollouts["name"]
  chart                 = local.argorollouts["chart"]
  version               = local.argorollouts["chart_version"]
  timeout               = local.argorollouts["timeout"]
  force_update          = local.argorollouts["force_update"]
  recreate_pods         = local.argorollouts["recreate_pods"]
  wait                  = local.argorollouts["wait"]
  atomic                = local.argorollouts["atomic"]
  cleanup_on_fail       = local.argorollouts["cleanup_on_fail"]
  dependency_update     = local.argorollouts["dependency_update"]
  disable_crd_hooks     = local.argorollouts["disable_crd_hooks"]
  disable_webhooks      = local.argorollouts["disable_webhooks"]
  render_subchart_notes = local.argorollouts["render_subchart_notes"]
  replace               = local.argorollouts["replace"]
  reset_values          = local.argorollouts["reset_values"]
  reuse_values          = local.argorollouts["reuse_values"]
  skip_crds             = local.argorollouts["skip_crds"]
  verify                = local.argorollouts["verify"]
  namespace             = "argo-rollouts"

  values = [
    file("${path.module}/helm/argo-rollouts/argo-rollouts-values.yaml")
  ]

  depends_on = [module.eks, kubernetes_namespace.argo-rollouts, data.http.wait_for_cluster]
}
