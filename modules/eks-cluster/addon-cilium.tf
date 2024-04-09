#---------------------------------------------------------------
# CILIUM AWS IAM ASSUME ROLE POLICY
#---------------------------------------------------------------
data "aws_iam_policy_document" "cilium_assume_role_policy" {
  statement {

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.account_id}:oidc-provider/${module.eks.oidc_provider}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:aud"

      values = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"

      values = ["system:serviceaccount:kube-system:cilium"]
    }

    effect = "Allow"
  }
}

#---------------------------------------------------------------
# CILIUM AWS IAM POLICY
#---------------------------------------------------------------
# Cilium IAM Policy
resource "aws_iam_policy" "cilium_iam_policy" {
  name        = "${var.cluster_name}-cilium-iam-policy"
  path        = "/"
  description = "${var.cluster_name}-cilium-iam-policy"
  policy      = file("${path.module}/iam/policies/cilium/cilium.json")
}

#---------------------------------------------------------------
# CILIUM IAM ROLE
#---------------------------------------------------------------
# Cilium
resource "aws_iam_role" "cilium_role" {
  name               = "cilium-irsa-${var.cluster_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.cilium_assume_role_policy.json
}

#---------------------------------------------------------------
# CILIUM IAM ROLE POLICY ATTACHMENT
#---------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "cilium_policy_attachment" {
  role       = aws_iam_role.cilium_role.name
  policy_arn = aws_iam_policy.cilium_iam_policy.arn
}

#---------------------------------------------------------------
# CILIUM KUBERNETES SERVICE ACCOUNT
#---------------------------------------------------------------
resource "kubernetes_service_account" "cilium_sa" {
  metadata {
    name      = "cilium"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.account_id}:role/cilium-irsa-${var.cluster_name}"
    }
  }

  depends_on = [
    module.eks,
    data.http.wait_for_cluster
  ]
}

#---------------------------------------------------------------
# CILIUM CLUSTER ROLE BINDING
#---------------------------------------------------------------
resource "kubernetes_cluster_role_binding" "cilium_cluster_role_binding" {

  count = local.addon_flag_cilium_cni

  metadata {
    name = "cilium"
    labels = {
      "app.kubernetes.io/part-of" : "cilium"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cilium"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cilium"
    namespace = "kube-system"
  }
}

#---------------------------------------------------------------
# CILIUM HELM CHART
#---------------------------------------------------------------
resource "helm_release" "cilium" {

  count = local.addon_flag_cilium_cni

  name       = "cilium"
  chart      = local.helm_dependencies[index(local.helm_dependencies.*.name, "cilium")].name
  repository = local.helm_dependencies[index(local.helm_dependencies.*.name, "cilium")].repository
  version    = local.helm_dependencies[index(local.helm_dependencies.*.name, "cilium")].version
  namespace  = "kube-system"
  atomic     = true

  values = [
    file("${path.module}/helm/cilium/cilium-values.yaml")
  ]

  set {
    name  = "cluster.name"
    value = var.cluster_name
    type  = "auto"
  }

  set {
    name  = "serviceAccounts.cilium.create"
    value = "false"
    type  = "auto"
  }

  set {
    name  = "serviceAccounts.cilium.name"
    value = "cilium"
    type  = "auto"
  }

  set {
    name  = "eni.enabled"
    value = "true"
    type  = "auto"
  }

  set {
    name  = "ipam.mode"
    value = "eni"
    type  = "auto"
  }

  set {
    name  = "egressMasqueradeInterfaces"
    value = "eth0"
    type  = "auto"
  }

  set {
    name  = "routingMode"
    value = "native"
    type  = "auto"
  }

  set {
    name  = "hubble.relay.enabled"
    value = "true"
    type  = "auto"
  }

  set {
    name  = "hubble.ui.enabled"
    value = "true"
    type  = "auto"
  }

  set {
    name  = "prometheus.enabled"
    value = "true"
    type  = "auto"
  }

  set {
    name  = "operator.prometheus.enabled"
    value = "true"
    type  = "auto"
  }

  set {
    name  = "hubble.metrics.enableOpenMetrics"
    value = "true"
    type  = "auto"
  }

  set {
    name  = "hubble.metrics.enabled"
    value = "{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\\,source_namespace\\,source_workload\\,destination_ip\\,destination_namespace\\,destination_workload\\,traffic_direction}"
    type  = "auto"
  }

  set {
    name  = "nodePort.enabled"
    value = "true"
    type  = "auto"
  }

  set {
    name  = "encryption.enabled"
    value = "true"
    type  = "auto"
  }

  set {
    name  = "encryption.type"
    value = "wireguard"
    type  = "auto"
  }

  set {
    name  = "authentication.mutual.spire.enabled"
    value = "true"
    type  = "auto"
  }

  set {
    name  = "authentication.mutual.spire.install.enabled"
    value = "true"
    type  = "auto"
  }

  # UN-COMMENT TO ENABLE CILIUM INGRESS CONTROLLER
  /*set {
    name  = "ingressController.enabled"
    value = "true"
    type  = "auto"
  }

  set {
    name  = "ingressController.loadbalancerMode"
    value = "dedicated"
    type  = "auto"
  }*/

  depends_on = [
    module.eks,
    data.http.wait_for_cluster
  ]

}