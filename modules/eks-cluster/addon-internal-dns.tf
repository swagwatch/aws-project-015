#---------------------------------------------------------------
# INTERNAL DNS AWS IAM ASSUME ROLE POLICY
#---------------------------------------------------------------
data "aws_iam_policy_document" "internal_dns_assume_role_policy" {
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

      values = ["system:serviceaccount:kube-system:internal-dns"]
    }

    effect = "Allow"
  }
}

#---------------------------------------------------------------
# INTERNAL DNS IAM POLICY
#---------------------------------------------------------------
resource "aws_iam_policy" "internal_dns_iam_policy" {
  name        = "${var.cluster_name}-internal-dns-iam-policy"
  path        = "/"
  description = "${var.cluster_name}-internal-dns-iam-policy"
  policy      = file("${path.module}/iam/policies/internal-dns/internal-dns.json")
}

#---------------------------------------------------------------
# INTERNAL DNS IAM ROLE
#---------------------------------------------------------------
resource "aws_iam_role" "internal_dns_role" {
  name               = "internal-dns-irsa-${var.cluster_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.internal_dns_assume_role_policy.json
}

#---------------------------------------------------------------
# INTERNAL DNS IAM POLICY ATTACHMENT
#---------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "internal_dns_policy_attachment" {
  role       = aws_iam_role.internal_dns_role.name
  policy_arn = aws_iam_policy.internal_dns_iam_policy.arn
}


#---------------------------------------------------------------
# INTERNAL DNS KUBERNERTES SERVICE ACCOUNT
#---------------------------------------------------------------
resource "kubernetes_service_account" "internal_dns_sa" {
  metadata {
    name      = "internal-dns"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.account_id}:role/internal-dns-irsa-${var.cluster_name}"
    }
  }

  depends_on = [
    module.eks,
    data.http.wait_for_cluster
  ]
}

#---------------------------------------------------------------
# INTERNAL DNS HELM CHART
#---------------------------------------------------------------
resource "helm_release" "internal_dns" {

  count = local.addon_flag_networking

  name      = "internal-dns"
  namespace = "kube-system"

  chart      = local.helm_dependencies[index(local.helm_dependencies.*.name, "internal-dns")].name
  repository = local.helm_dependencies[index(local.helm_dependencies.*.name, "internal-dns")].repository
  version    = local.helm_dependencies[index(local.helm_dependencies.*.name, "internal-dns")].version
  atomic     = true

  values = [
    file("${path.module}/helm/internal-dns/internal-dns-values.yaml")
  ]

  set {
    name  = "domainFilter"
    value = var.private_domain_filter
    type  = "auto"
  }

  depends_on = [
    module.eks,
    kubernetes_service_account.internal_dns_sa,
    data.http.wait_for_cluster
  ]
}
