# locals.tf

locals {

  addon_flag_cilium_cni = var.addon_cilium_cni_enabled == true ? 1 : 0

  addon_flag_ekscore = var.addon_ekscore_enabled == true ? 1 : 0

  addon_flag_storage = var.addon_storage_enabled == true ? 1 : 0

  addon_flag_networking = var.addon_networking_enabled == true ? 1 : 0

  addon_flag_monitoring = var.addon_monitoring_enabled == true ? 1 : 0

  addon_flag_sdlc = var.addon_sdlc_enabled == true ? 1 : 0

  helm_defaults_defaults = {
    atomic                = true
    cleanup_on_fail       = true
    dependency_update     = false
    disable_crd_hooks     = false
    disable_webhooks      = false
    force_update          = false
    recreate_pods         = false
    render_subchart_notes = true
    replace               = false
    reset_values          = false
    reuse_values          = false
    skip_crds             = false
    timeout               = 600
    verify                = false
    wait                  = true
    extra_values          = ""
  }

  helm_defaults = merge(
    local.helm_defaults_defaults,
    var.helm_defaults
  )

  iam_role_name = var.eks_iam_role_name

  helm_dependencies = yamldecode(file("${path.module}/helm-dependencies.yaml"))["dependencies"]

  default_tags = ["cluster_name:${var.cluster_name}", "terraform:true"]
  tags         = concat(local.default_tags, var.tags)
}