locals {

  prometheus = merge(
    local.helm_defaults,
    {
      name          = local.helm_dependencies[index(local.helm_dependencies.*.name, "prometheus")].name
      chart         = local.helm_dependencies[index(local.helm_dependencies.*.name, "prometheus")].name
      repository    = local.helm_dependencies[index(local.helm_dependencies.*.name, "prometheus")].repository
      chart_version = local.helm_dependencies[index(local.helm_dependencies.*.name, "prometheus")].version
    }
  )

  loki = merge(
    local.helm_defaults,
    {
      name          = local.helm_dependencies[index(local.helm_dependencies.*.name, "loki-stack")].name
      chart         = local.helm_dependencies[index(local.helm_dependencies.*.name, "loki-stack")].name
      repository    = local.helm_dependencies[index(local.helm_dependencies.*.name, "loki-stack")].repository
      chart_version = local.helm_dependencies[index(local.helm_dependencies.*.name, "loki-stack")].version
    }
  )

  grafana = merge(
    local.helm_defaults,
    {
      name          = local.helm_dependencies[index(local.helm_dependencies.*.name, "grafana")].name
      chart         = local.helm_dependencies[index(local.helm_dependencies.*.name, "grafana")].name
      repository    = local.helm_dependencies[index(local.helm_dependencies.*.name, "grafana")].repository
      chart_version = local.helm_dependencies[index(local.helm_dependencies.*.name, "grafana")].version
    }
  )
}


resource "kubernetes_namespace" "monitoring" {

  count = local.addon_flag_monitoring

  metadata {
    name = "monitoring"
  }

  depends_on = [module.eks, data.http.wait_for_cluster]
}


resource "helm_release" "prometheus" {

  count = local.addon_flag_monitoring

  repository            = local.prometheus["repository"]
  name                  = local.prometheus["name"]
  chart                 = local.prometheus["chart"]
  version               = local.prometheus["chart_version"]
  timeout               = local.prometheus["timeout"]
  force_update          = local.prometheus["force_update"]
  recreate_pods         = local.prometheus["recreate_pods"]
  wait                  = local.prometheus["wait"]
  atomic                = local.prometheus["atomic"]
  cleanup_on_fail       = local.prometheus["cleanup_on_fail"]
  dependency_update     = local.prometheus["dependency_update"]
  disable_crd_hooks     = local.prometheus["disable_crd_hooks"]
  disable_webhooks      = local.prometheus["disable_webhooks"]
  render_subchart_notes = local.prometheus["render_subchart_notes"]
  replace               = local.prometheus["replace"]
  reset_values          = local.prometheus["reset_values"]
  reuse_values          = local.prometheus["reuse_values"]
  skip_crds             = local.prometheus["skip_crds"]
  verify                = local.prometheus["verify"]
  namespace             = "monitoring"

  values = [
    file("${path.module}/helm/prometheus/extraScrapeConfigs.yaml")
  ]

  /*set {
    name  = "alertmanager.persistentVolume.storageClass"
    value = "ebs-sc"
    type  = "string"
  }*/

  set {
    name  = "prometheus-pushgateway.enabled"
    value = "false"
    type  = "auto"
  }

  set {
    name  = "alertmanager.enabled"
    value = "false"
    type  = "auto"
  }

  set {
    name  = "server.persistentVolume.storageClass"
    value = "ebs-sc"
    type  = "string"
  }

  depends_on = [module.eks, kubernetes_namespace.monitoring, data.http.wait_for_cluster]
}


resource "helm_release" "loki" {

  count = local.addon_flag_monitoring

  repository            = local.loki["repository"]
  name                  = local.loki["name"]
  chart                 = local.loki["chart"]
  version               = local.loki["chart_version"]
  timeout               = local.loki["timeout"]
  force_update          = local.loki["force_update"]
  recreate_pods         = local.loki["recreate_pods"]
  wait                  = local.loki["wait"]
  atomic                = local.loki["atomic"]
  cleanup_on_fail       = local.loki["cleanup_on_fail"]
  dependency_update     = local.loki["dependency_update"]
  disable_crd_hooks     = local.loki["disable_crd_hooks"]
  disable_webhooks      = local.loki["disable_webhooks"]
  render_subchart_notes = local.loki["render_subchart_notes"]
  replace               = local.loki["replace"]
  reset_values          = local.loki["reset_values"]
  reuse_values          = local.loki["reuse_values"]
  skip_crds             = local.loki["skip_crds"]
  verify                = local.loki["verify"]
  namespace             = "monitoring"

  values = [
    file("${path.module}/helm/loki/loki-values.yaml")
  ]

  depends_on = [module.eks, kubernetes_namespace.monitoring, data.http.wait_for_cluster]
}


resource "helm_release" "grafana" {

  count = local.addon_flag_monitoring

  repository            = local.grafana["repository"]
  name                  = local.grafana["name"]
  chart                 = local.grafana["chart"]
  version               = local.grafana["chart_version"]
  timeout               = local.grafana["timeout"]
  force_update          = local.grafana["force_update"]
  recreate_pods         = local.grafana["recreate_pods"]
  wait                  = local.grafana["wait"]
  atomic                = local.grafana["atomic"]
  cleanup_on_fail       = local.grafana["cleanup_on_fail"]
  dependency_update     = local.grafana["dependency_update"]
  disable_crd_hooks     = local.grafana["disable_crd_hooks"]
  disable_webhooks      = local.grafana["disable_webhooks"]
  render_subchart_notes = local.grafana["render_subchart_notes"]
  replace               = local.grafana["replace"]
  reset_values          = local.grafana["reset_values"]
  reuse_values          = local.grafana["reuse_values"]
  skip_crds             = local.grafana["skip_crds"]
  verify                = local.grafana["verify"]
  namespace             = "monitoring"

  values = [
    file("${path.module}/helm/grafana/grafana-values.yaml")
  ]

  set {
    name  = "persistence.storageClassName"
    value = "ebs-sc"
    type  = "string"
  }

  set {
    name  = "adminPassword"
    value = "awseks!isawesome!"
    type  = "string"
  }

  set {
    name  = "persistence.enabled"
    value = true
    type  = "auto"
  }

  depends_on = [module.eks, kubernetes_namespace.monitoring, data.http.wait_for_cluster, helm_release.prometheus]

  # depends_on = [module.eks, kubernetes_namespace.monitoring, helm_release.prometheus, helm_release.loki, data.http.wait_for_cluster]
}


resource "helm_release" "opencost" {

  count = local.addon_flag_monitoring

  name             = "opencost"
  namespace        = "opencost"
  create_namespace = true

  chart      = local.helm_dependencies[index(local.helm_dependencies.*.name, "opencost")].name
  repository = local.helm_dependencies[index(local.helm_dependencies.*.name, "opencost")].repository
  version    = local.helm_dependencies[index(local.helm_dependencies.*.name, "opencost")].version
  atomic     = true

  depends_on = [
    module.eks,
    helm_release.prometheus,
    data.http.wait_for_cluster
  ]
}
