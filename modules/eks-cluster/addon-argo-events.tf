locals {
  argoevents = merge(
    local.helm_defaults,
    {
      name          = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-events")].name
      chart         = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-events")].name
      repository    = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-events")].repository
      chart_version = local.helm_dependencies[index(local.helm_dependencies.*.name, "argo-events")].version
    }
  )
}

resource "kubernetes_namespace" "argo-events" {

  count = local.addon_flag_sdlc

  metadata {
    name = "argo-events"
  }
  depends_on = [module.eks, data.http.wait_for_cluster]
}

resource "helm_release" "argo-events" {

  count = local.addon_flag_sdlc

  repository            = local.argoevents["repository"]
  name                  = local.argoevents["name"]
  chart                 = local.argoevents["chart"]
  version               = local.argoevents["chart_version"]
  timeout               = local.argoevents["timeout"]
  force_update          = local.argoevents["force_update"]
  recreate_pods         = local.argoevents["recreate_pods"]
  wait                  = local.argoevents["wait"]
  atomic                = local.argoevents["atomic"]
  cleanup_on_fail       = local.argoevents["cleanup_on_fail"]
  dependency_update     = local.argoevents["dependency_update"]
  disable_crd_hooks     = local.argoevents["disable_crd_hooks"]
  disable_webhooks      = local.argoevents["disable_webhooks"]
  render_subchart_notes = local.argoevents["render_subchart_notes"]
  replace               = local.argoevents["replace"]
  reset_values          = local.argoevents["reset_values"]
  reuse_values          = local.argoevents["reuse_values"]
  skip_crds             = local.argoevents["skip_crds"]
  verify                = local.argoevents["verify"]
  namespace             = "argo-events"

  values = [
    file("${path.module}/helm/argo-events/argo-events-values.yaml")
  ]

  depends_on = [module.eks, kubernetes_namespace.argo-events, data.http.wait_for_cluster]
}
