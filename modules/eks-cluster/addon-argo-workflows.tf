locals {

  argoworkflows = merge(
    local.helm_defaults,
    {
      name          = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-workflows")].name
      chart         = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-workflows")].name
      repository    = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-workflows")].repository
      chart_version = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-workflows")].version
    }
  )
}

resource "kubernetes_namespace" "argo-workflows" {

  count = local.addon_flag_sdlc

  metadata {
    name = "argo"
  }
  depends_on = [module.eks, data.http.wait_for_cluster]
}

resource "helm_release" "argo-workflows" {

  count = local.addon_flag_sdlc

  repository            = local.argoworkflows["repository"]
  name                  = local.argoworkflows["name"]
  chart                 = local.argoworkflows["chart"]
  version               = local.argoworkflows["chart_version"]
  timeout               = local.argoworkflows["timeout"]
  force_update          = local.argoworkflows["force_update"]
  recreate_pods         = local.argoworkflows["recreate_pods"]
  wait                  = local.argoworkflows["wait"]
  atomic                = local.argoworkflows["atomic"]
  cleanup_on_fail       = local.argoworkflows["cleanup_on_fail"]
  dependency_update     = local.argoworkflows["dependency_update"]
  disable_crd_hooks     = local.argoworkflows["disable_crd_hooks"]
  disable_webhooks      = local.argoworkflows["disable_webhooks"]
  render_subchart_notes = local.argoworkflows["render_subchart_notes"]
  replace               = local.argoworkflows["replace"]
  reset_values          = local.argoworkflows["reset_values"]
  reuse_values          = local.argoworkflows["reuse_values"]
  skip_crds             = local.argoworkflows["skip_crds"]
  verify                = local.argoworkflows["verify"]
  namespace             = "argo"

  values = [
    file("${path.module}/helm/argo-workflows/argo-workflows-values.yaml")
  ]

  depends_on = [module.eks, kubernetes_namespace.argo-workflows, data.http.wait_for_cluster]
}
