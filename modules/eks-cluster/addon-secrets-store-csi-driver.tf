
locals {

  sscd = merge(
    local.helm_defaults,
    {
      name          = local.helm_dependencies[index(local.helm_dependencies.*.name, "secrets-store-csi-driver")].name
      chart         = local.helm_dependencies[index(local.helm_dependencies.*.name, "secrets-store-csi-driver")].name
      repository    = local.helm_dependencies[index(local.helm_dependencies.*.name, "secrets-store-csi-driver")].repository
      chart_version = local.helm_dependencies[index(local.helm_dependencies.*.name, "secrets-store-csi-driver")].version
    }
  )
}

resource "helm_release" "secrets-store-csi-driver" {

  count = local.addon_flag_storage

  repository            = local.sscd["repository"]
  name                  = local.sscd["name"]
  chart                 = local.sscd["chart"]
  version               = local.sscd["chart_version"]
  timeout               = local.sscd["timeout"]
  force_update          = local.sscd["force_update"]
  recreate_pods         = local.sscd["recreate_pods"]
  wait                  = local.sscd["wait"]
  atomic                = local.sscd["atomic"]
  cleanup_on_fail       = local.sscd["cleanup_on_fail"]
  dependency_update     = local.sscd["dependency_update"]
  disable_crd_hooks     = local.sscd["disable_crd_hooks"]
  disable_webhooks      = local.sscd["disable_webhooks"]
  render_subchart_notes = local.sscd["render_subchart_notes"]
  replace               = local.sscd["replace"]
  reset_values          = local.sscd["reset_values"]
  reuse_values          = local.sscd["reuse_values"]
  skip_crds             = local.sscd["skip_crds"]
  verify                = local.sscd["verify"]
  namespace             = "kube-system"

  values = [
    file("${path.module}/helm/sscd/sscd-values.yaml")
  ]

  set {
    name  = "syncSecret.enabled"
    value = true
    type  = "auto"
  }

  set {
    name  = "enableSecretRotation"
    value = true
    type  = "auto"
  }

  depends_on = [
    module.eks,
    data.http.wait_for_cluster
  ]
}
