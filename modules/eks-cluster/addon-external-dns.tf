#---------------------------------------------------------------
# EXTERNAL DNS AWS IAM ASSUME ROLE POLICY
#---------------------------------------------------------------
data "aws_iam_policy_document" "external_dns_assume_role_policy" {
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

      values = ["system:serviceaccount:kube-system:external-dns"]
    }

    effect = "Allow"
  }
}

#---------------------------------------------------------------
# EXTERNAL DNS AWS IAM ROLE POLICY
#---------------------------------------------------------------
resource "aws_iam_policy" "external_dns_iam_policy" {
  name        = "${var.cluster_name}-external-dns-iam-policy"
  path        = "/"
  description = "${var.cluster_name}-external-dns-iam-policy"
  policy      = file("${path.module}/iam/policies/external-dns/external-dns.json")
}

#---------------------------------------------------------------
# EXTERNAL DNS AWS IAM ROLE
#---------------------------------------------------------------
resource "aws_iam_role" "external_dns_role" {
  name               = "external-dns-irsa-${var.cluster_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role_policy.json
}

#---------------------------------------------------------------
# EXTERNAL DNS AWS IAM ROLE POLICY ATTACHMENT
#---------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "external_dns_policy_attachment" {
  role       = aws_iam_role.external_dns_role.name
  policy_arn = aws_iam_policy.external_dns_iam_policy.arn
}

#---------------------------------------------------------------
# EXTERNAL DNS KUBERNETES SERVICE ACCOUNT
#---------------------------------------------------------------
resource "kubernetes_service_account" "external_dns_sa" {
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.account_id}:role/external-dns-irsa-${var.cluster_name}"
    }
  }

  depends_on = [
    module.eks,
    data.http.wait_for_cluster
  ]
}

#---------------------------------------------------------------
# EXTERNAL DNS HELM CHART
#---------------------------------------------------------------
resource "helm_release" "external_dns" {

  count = local.addon_flag_networking

  name      = "external-dns"
  namespace = "kube-system"

  chart      = local.helm_dependencies[index(local.helm_dependencies.*.name, "external-dns")].name
  repository = local.helm_dependencies[index(local.helm_dependencies.*.name, "external-dns")].repository
  version    = local.helm_dependencies[index(local.helm_dependencies.*.name, "external-dns")].version
  atomic     = true

  values = [
    file("${path.module}/helm/external-dns/external-dns-values.yaml")
  ]

  set {
    name  = "domainFilter"
    value = var.public_domain_filter
    type  = "auto"
  }

  depends_on = [
    module.eks,
    kubernetes_service_account.external_dns_sa,
    data.http.wait_for_cluster
  ]
}
