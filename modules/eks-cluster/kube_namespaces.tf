# kube_namespaces.tf

data "aws_iam_policy_document" "team_black_namespace_iam_assume_role_policy" {
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

      values = ["system:serviceaccount:team-black:team-black-sa"]
    }

    effect = "Allow"
  }
}


data "aws_iam_policy_document" "team_green_namespace_iam_assume_role_policy" {
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

      values = ["system:serviceaccount:team-green:team-green-sa"]
    }

    effect = "Allow"
  }
}


data "aws_iam_policy_document" "team_white_namespace_iam_assume_role_policy" {
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

      values = ["system:serviceaccount:team-white:team-white-sa"]
    }

    effect = "Allow"
  }
}


# Team Black EKS Namespace IAM Policy
resource "aws_iam_policy" "team_black_namespace_iam_policy" {
  name        = "${var.cluster_name}-team-black-namespace-iam-policy"
  path        = "/"
  description = "${var.cluster_name}-team-black-namespace-iam-policy"
  policy      = file("${path.module}/iam/policies/application-policies/team-black-namespace-iam-policy.json")
}


# Team Green EKS Namespace IAM Policy
resource "aws_iam_policy" "team_green_namespace_iam_policy" {
  name        = "${var.cluster_name}-team-green-namespace-iam-policy"
  path        = "/"
  description = "${var.cluster_name}-team-green-namespace-iam-policy"
  policy      = file("${path.module}/iam/policies/application-policies/team-green-namespace-iam-policy.json")
}


# Team White EKS Namespace IAM Policy
resource "aws_iam_policy" "team_white_namespace_iam_policy" {
  name        = "${var.cluster_name}-team-white-namespace-iam-policy"
  path        = "/"
  description = "${var.cluster_name}-team-white-namespace-iam-policy"
  policy      = file("${path.module}/iam/policies/application-policies/team-white-namespace-iam-policy.json")
}


# AWS IAM ROLES FOR SERVICE ACCOUNTS

# APPLICATION NAMESPACES
resource "aws_iam_role" "team_black_namespace_iam_role_for_service_account" {
  name               = "team-black-irsa-${var.cluster_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.team_black_namespace_iam_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "team_black_namespace_irsa_policy_attachment" {
  role       = aws_iam_role.team_black_namespace_iam_role_for_service_account.name
  policy_arn = aws_iam_policy.team_black_namespace_iam_policy.arn
}

resource "aws_iam_role" "team_green_namespace_iam_role_for_service_account" {
  name               = "team-green-irsa-${var.cluster_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.team_green_namespace_iam_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "team_green_namespace_irsa_policy_attachment" {
  role       = aws_iam_role.team_green_namespace_iam_role_for_service_account.name
  policy_arn = aws_iam_policy.team_green_namespace_iam_policy.arn
}

resource "aws_iam_role" "team_white_namespace_iam_role_for_service_account" {
  name               = "team-white-irsa-${var.cluster_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.team_white_namespace_iam_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "team_white_namespace_irsa_policy_attachment" {
  role       = aws_iam_role.team_white_namespace_iam_role_for_service_account.name
  policy_arn = aws_iam_policy.team_white_namespace_iam_policy.arn
}


resource "kubernetes_namespace" "ns" {
  for_each = toset(var.kube_namespaces)
  metadata {
    annotations = {
      name = each.key
    }

    labels = {
      "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled"
      "certmanager.k8s.io/disable-validation"   = "true"
    }

    name = each.key
  }

  depends_on = [
    module.eks,
    data.http.wait_for_cluster
  ]
}


resource "kubernetes_service_account" "app_ns_sa" {
  for_each = toset(var.kube_namespaces)

  metadata {
    name      = "${each.key}-sa"
    namespace = each.key
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.account_id}:role/${each.key}-irsa-${var.cluster_name}"
    }
  }

  depends_on = [
    kubernetes_namespace.ns,
    module.eks,
    data.http.wait_for_cluster
  ]
}




