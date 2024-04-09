#---------------------------------------------------------------
# CERT MANAGER AWS IAM ASSUME ROLE POLICY
#---------------------------------------------------------------
data "aws_iam_policy_document" "cert_manager_assume_role_policy" {
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

      values = ["system:serviceaccount:cert-manager:cert-manager"]
    }

    effect = "Allow"
  }
}

#---------------------------------------------------------------
# CERT MANAGER AWS IAM POLICY
#---------------------------------------------------------------
# Cert Manager ACME DNS Challenge IAM Policy
resource "aws_iam_policy" "cert_manager_iam_policy" {
  name        = "${var.cluster_name}-cert-manager-iam-policy"
  path        = "/"
  description = "${var.cluster_name}-cert-manager-iam-policy"
  policy      = file("${path.module}/iam/policies/cert-manager/cert-manager.json")
}

#---------------------------------------------------------------
# CERT MANAGER IAM ROLE
#---------------------------------------------------------------
# Cert Manager
resource "aws_iam_role" "cert_manager_role" {
  name               = "cert-manager-irsa-${var.cluster_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.cert_manager_assume_role_policy.json
}

#---------------------------------------------------------------
# CERT MANAGER IAM ROLE POLICY ATTACHMENT
#---------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "cert_manager_policy_attachment" {
  role       = aws_iam_role.cert_manager_role.name
  policy_arn = aws_iam_policy.cert_manager_iam_policy.arn
}


#---------------------------------------------------------------
# CERT MANAGER KUBERNETES NAMESPACE
#---------------------------------------------------------------
resource "kubernetes_namespace" "cert_manager" {

  count = local.addon_flag_networking

  metadata {
    name = "cert-manager"
  }
  depends_on = [
    module.eks,
    data.http.wait_for_cluster
  ]
}

#---------------------------------------------------------------
# CERT MANAGER KUBERNETES SERVICE ACCOUNT
#---------------------------------------------------------------
resource "kubernetes_service_account" "cert_manager" {

  count = local.addon_flag_networking

  metadata {
    name      = "cert-manager"
    namespace = "cert-manager"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.account_id}:role/cert-manager-irsa-${var.cluster_name}"
    }
  }

  depends_on = [
    module.eks,
    kubernetes_namespace.cert_manager,
    data.http.wait_for_cluster
  ]
}

#---------------------------------------------------------------
# CERT MANAGER HELM CHART
#---------------------------------------------------------------
resource "helm_release" "cert_manager" {

  count = local.addon_flag_networking

  name      = "cert-manager"
  namespace = "cert-manager"

  chart      = local.helm_dependencies[index(local.helm_dependencies.*.name, "cert-manager")].name
  repository = local.helm_dependencies[index(local.helm_dependencies.*.name, "cert-manager")].repository
  version    = local.helm_dependencies[index(local.helm_dependencies.*.name, "cert-manager")].version
  atomic     = true

  depends_on = [
    module.eks,
    kubernetes_service_account.cert_manager,
    data.http.wait_for_cluster
  ]
}

#---------------------------------------------------------------
# CERT MANAGER SSL CERTIFICATE NAMESPACE
#---------------------------------------------------------------
resource "kubernetes_namespace" "ssl_certificates" {

  count = local.addon_flag_networking

  metadata {
    name = "ssl-certificates"
  }
  depends_on = [
    module.eks,
    data.http.wait_for_cluster
  ]
}
