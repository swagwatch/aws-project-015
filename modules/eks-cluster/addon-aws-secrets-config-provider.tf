locals {

  ascp = merge(
    local.helm_defaults,
    {
      name          = local.helm_dependencies[index(local.helm_dependencies.*.name, "aws-secrets-manager")].name
      chart         = "secrets-store-csi-driver-provider-aws"
      repository    = local.helm_dependencies[index(local.helm_dependencies.*.name, "aws-secrets-manager")].repository
      chart_version = local.helm_dependencies[index(local.helm_dependencies.*.name, "aws-secrets-manager")].version
    }
  )
}

resource "helm_release" "aws-secrets-manager" {

  count = local.addon_flag_storage

  repository            = local.ascp["repository"]
  name                  = local.ascp["name"]
  chart                 = local.ascp["chart"]
  version               = local.ascp["chart_version"]
  timeout               = local.ascp["timeout"]
  force_update          = local.ascp["force_update"]
  recreate_pods         = local.ascp["recreate_pods"]
  wait                  = local.ascp["wait"]
  atomic                = local.ascp["atomic"]
  cleanup_on_fail       = local.ascp["cleanup_on_fail"]
  dependency_update     = local.ascp["dependency_update"]
  disable_crd_hooks     = local.ascp["disable_crd_hooks"]
  disable_webhooks      = local.ascp["disable_webhooks"]
  render_subchart_notes = local.ascp["render_subchart_notes"]
  replace               = local.ascp["replace"]
  reset_values          = local.ascp["reset_values"]
  reuse_values          = local.ascp["reuse_values"]
  skip_crds             = local.ascp["skip_crds"]
  verify                = local.ascp["verify"]
  namespace             = "kube-system"

  values = [
    file("${path.module}/helm/ascp/ascp-values.yaml")
  ]

  depends_on = [module.eks, data.http.wait_for_cluster]
}
