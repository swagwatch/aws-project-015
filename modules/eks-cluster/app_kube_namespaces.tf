#---------------------------------------------------------------
# APP reviews NAMESPACE AWS IAM ASSUME ROLE POLICY
#---------------------------------------------------------------
data "aws_iam_policy_document" "app_reviews_namespace_iam_assume_role_policy" {
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

      values = ["system:serviceaccount:app-reviews:app-reviews-sa"]
    }

    effect = "Allow"
  }
}

#---------------------------------------------------------------
# APP reviews NAMESPACE AWS IAM POLICY
#---------------------------------------------------------------
resource "aws_iam_policy" "app_reviews_namespace_iam_policy" {
  name        = "${var.cluster_name}-app-reviews-namespace-iam-policy"
  path        = "/"
  description = "${var.cluster_name}-app-reviews-namespace-iam-policy"
  policy      = file("${path.module}/iam/policies/application-policies/app-reviews-namespace-iam-policy.json")
}

#---------------------------------------------------------------
# APP reviews NAMESPACE AWS IAM ROLE
#---------------------------------------------------------------
resource "aws_iam_role" "app_reviews_namespace_iam_role_for_service_account" {
  name               = "app-reviews-irsa-${var.cluster_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.app_reviews_namespace_iam_assume_role_policy.json
}

#---------------------------------------------------------------
# APP reviews NAMESPACE AWS IAM ROLE POLICY ATTACHMENT
#---------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "app_reviews_namespace_irsa_policy_attachment" {
  role       = aws_iam_role.app_reviews_namespace_iam_role_for_service_account.name
  policy_arn = aws_iam_policy.app_reviews_namespace_iam_policy.arn
}


#---------------------------------------------------------------
# APP payments NAMESPACE AWS IAM ASSUME ROLE POLICY
#---------------------------------------------------------------
data "aws_iam_policy_document" "app_payments_namespace_iam_assume_role_policy" {
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

      values = ["system:serviceaccount:app-payments:app-payments-sa"]
    }

    effect = "Allow"
  }
}

#---------------------------------------------------------------
# APP payments NAMESPACE AWS IAM POLICY
#---------------------------------------------------------------
resource "aws_iam_policy" "app_payments_namespace_iam_policy" {
  name        = "${var.cluster_name}-app-payments-namespace-iam-policy"
  path        = "/"
  description = "${var.cluster_name}-app-payments-namespace-iam-policy"
  policy      = file("${path.module}/iam/policies/application-policies/app-payments-namespace-iam-policy.json")
}

#---------------------------------------------------------------
# APP payments NAMESPACE AWS IAM ROLE
#---------------------------------------------------------------
resource "aws_iam_role" "app_payments_namespace_iam_role_for_service_account" {
  name               = "app-payments-irsa-${var.cluster_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.app_payments_namespace_iam_assume_role_policy.json
}

#---------------------------------------------------------------
# APP payments NAMESPACE AWS IAM ROLE POLICY ATTACHMENT
#---------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "app_payments_namespace_irsa_policy_attachment" {
  role       = aws_iam_role.app_payments_namespace_iam_role_for_service_account.name
  policy_arn = aws_iam_policy.app_payments_namespace_iam_policy.arn
}


#---------------------------------------------------------------
# APP orders NAMESPACE AWS IAM ASSUME ROLE POLICY
#---------------------------------------------------------------
data "aws_iam_policy_document" "app_orders_namespace_iam_assume_role_policy" {
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

      values = ["system:serviceaccount:app-orders:app-orders-sa"]
    }

    effect = "Allow"
  }
}

#---------------------------------------------------------------
# APP orders NAMESPACE AWS IAM POLICY
#---------------------------------------------------------------
resource "aws_iam_policy" "app_orders_namespace_iam_policy" {
  name        = "${var.cluster_name}-app-orders-namespace-iam-policy"
  path        = "/"
  description = "${var.cluster_name}-app-orders-namespace-iam-policy"
  policy      = file("${path.module}/iam/policies/application-policies/app-orders-namespace-iam-policy.json")
}

#---------------------------------------------------------------
# APP orders NAMESPACE AWS IAM ROLE
#---------------------------------------------------------------
resource "aws_iam_role" "app_orders_namespace_iam_role_for_service_account" {
  name               = "app-orders-irsa-${var.cluster_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.app_orders_namespace_iam_assume_role_policy.json
}

#---------------------------------------------------------------
# APP orders NAMESPACE AWS IAM ROLE POLICY ATTACHMENT
#---------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "app_orders_namespace_irsa_policy_attachment" {
  role       = aws_iam_role.app_orders_namespace_iam_role_for_service_account.name
  policy_arn = aws_iam_policy.app_orders_namespace_iam_policy.arn
}


#---------------------------------------------------------------
# APP search NAMESPACE AWS IAM ASSUME ROLE POLICY
#---------------------------------------------------------------
data "aws_iam_policy_document" "app_search_namespace_iam_assume_role_policy" {
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

      values = ["system:serviceaccount:app-search:app-search-sa"]
    }

    effect = "Allow"
  }
}

#---------------------------------------------------------------
# APP search NAMESPACE AWS IAM POLICY
#---------------------------------------------------------------
resource "aws_iam_policy" "app_search_namespace_iam_policy" {
  name        = "${var.cluster_name}-app-search-namespace-iam-policy"
  path        = "/"
  description = "${var.cluster_name}-app-search-namespace-iam-policy"
  policy      = file("${path.module}/iam/policies/application-policies/app-search-namespace-iam-policy.json")
}

#---------------------------------------------------------------
# APP search NAMESPACE AWS IAM ROLE
#---------------------------------------------------------------
resource "aws_iam_role" "app_search_namespace_iam_role_for_service_account" {
  name               = "app-search-irsa-${var.cluster_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.app_search_namespace_iam_assume_role_policy.json
}

#---------------------------------------------------------------
# APP search NAMESPACE AWS IAM ROLE POLICY ATTACHMENT
#---------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "app_search_namespace_irsa_policy_attachment" {
  role       = aws_iam_role.app_search_namespace_iam_role_for_service_account.name
  policy_arn = aws_iam_policy.app_search_namespace_iam_policy.arn
}


#---------------------------------------------------------------
# APP products NAMESPACE AWS IAM ASSUME ROLE POLICY
#---------------------------------------------------------------
data "aws_iam_policy_document" "app_products_namespace_iam_assume_role_policy" {
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

      values = ["system:serviceaccount:app-products:app-products-sa"]
    }

    effect = "Allow"
  }
}

#---------------------------------------------------------------
# APP products NAMESPACE AWS IAM POLICY
#---------------------------------------------------------------
resource "aws_iam_policy" "app_products_namespace_iam_policy" {
  name        = "${var.cluster_name}-app-products-namespace-iam-policy"
  path        = "/"
  description = "${var.cluster_name}-app-products-namespace-iam-policy"
  policy      = file("${path.module}/iam/policies/application-policies/app-products-namespace-iam-policy.json")
}

#---------------------------------------------------------------
# APP products NAMESPACE AWS IAM ROLE
#---------------------------------------------------------------
resource "aws_iam_role" "app_products_namespace_iam_role_for_service_account" {
  name               = "app-products-irsa-${var.cluster_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.app_products_namespace_iam_assume_role_policy.json
}

#---------------------------------------------------------------
# APP products NAMESPACE AWS IAM ROLE POLICY ATTACHMENT
#---------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "app_products_namespace_irsa_policy_attachment" {
  role       = aws_iam_role.app_products_namespace_iam_role_for_service_account.name
  policy_arn = aws_iam_policy.app_products_namespace_iam_policy.arn
}


#---------------------------------------------------------------
# APP IDENTITY NAMESPACE AWS IAM ASSUME ROLE POLICY
#---------------------------------------------------------------
data "aws_iam_policy_document" "app_identity_namespace_iam_assume_role_policy" {
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

      values = ["system:serviceaccount:app-identity:app-identity-sa"]
    }

    effect = "Allow"
  }
}

#---------------------------------------------------------------
# APP IDENTITY NAMESPACE AWS IAM POLICY
#---------------------------------------------------------------
resource "aws_iam_policy" "app_identity_namespace_iam_policy" {
  name        = "${var.cluster_name}-app-identity-namespace-iam-policy"
  path        = "/"
  description = "${var.cluster_name}-app-identity-namespace-iam-policy"
  policy      = file("${path.module}/iam/policies/application-policies/app-identity-namespace-iam-policy.json")
}

#---------------------------------------------------------------
# APP IDENTITY NAMESPACE AWS IAM ROLE
#---------------------------------------------------------------
resource "aws_iam_role" "app_identity_namespace_iam_role_for_service_account" {
  name               = "app-identity-irsa-${var.cluster_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.app_identity_namespace_iam_assume_role_policy.json
}

#---------------------------------------------------------------
# APP IDENTITY NAMESPACE AWS IAM ROLE POLICY ATTACHMENT
#---------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "app_identity_namespace_irsa_policy_attachment" {
  role       = aws_iam_role.app_identity_namespace_iam_role_for_service_account.name
  policy_arn = aws_iam_policy.app_identity_namespace_iam_policy.arn
}


#---------------------------------------------------------------
# APP FRONTEND NAMESPACE AWS IAM ASSUME ROLE POLICY
#---------------------------------------------------------------
data "aws_iam_policy_document" "app_frontend_namespace_iam_assume_role_policy" {
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

      values = ["system:serviceaccount:app-frontend:app-frontend-sa"]
    }

    effect = "Allow"
  }
}

#---------------------------------------------------------------
# APP FRONTEND NAMESPACE AWS IAM POLICY
#---------------------------------------------------------------
resource "aws_iam_policy" "app_frontend_namespace_iam_policy" {
  name        = "${var.cluster_name}-app-frontend-namespace-iam-policy"
  path        = "/"
  description = "${var.cluster_name}-app-frontend-namespace-iam-policy"
  policy      = file("${path.module}/iam/policies/application-policies/app-frontend-namespace-iam-policy.json")
}

#---------------------------------------------------------------
# APP FRONTEND NAMESPACE AWS IAM ROLE
#---------------------------------------------------------------
resource "aws_iam_role" "app_frontend_namespace_iam_role_for_service_account" {
  name               = "app-frontend-irsa-${var.cluster_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.app_frontend_namespace_iam_assume_role_policy.json
}

#---------------------------------------------------------------
# APP FRONTEND NAMESPACE AWS IAM ROLE POLICY ATTACHMENT
#---------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "app_frontend_namespace_irsa_policy_attachment" {
  role       = aws_iam_role.app_frontend_namespace_iam_role_for_service_account.name
  policy_arn = aws_iam_policy.app_frontend_namespace_iam_policy.arn
}




#---------------------------------------------------------------
# KUBERNETES APP NAMESPACES
#---------------------------------------------------------------
resource "kubernetes_namespace" "app_namespaces" {
  for_each = toset(var.app_kube_namespaces)

  metadata {
    name = each.key

    annotations = {
      name = each.key
    }

    labels = {
      # "appmesh.k8s.aws/sidecarInjectorWebhook"  = "enabled"
      "certmanager.k8s.io/disable-validation"   = "true"
      "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled"
      # "mesh"                                    = "fullstack-dev"
    }
  }

  depends_on = [
    module.eks,
    data.http.wait_for_cluster
  ]
}


#---------------------------------------------------------------
# KUBERNETES APP NAMESPACE SERVICE ACCOUNTS
#---------------------------------------------------------------
resource "kubernetes_service_account" "app_namespace_serviceaccounts" {
  for_each = toset(var.app_kube_namespaces)

  metadata {
    name      = "${each.key}-sa"
    namespace = each.key
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.account_id}:role/${each.key}-irsa-${var.cluster_name}"
    }
  }

  depends_on = [
    kubernetes_namespace.app_namespaces,
    module.eks,
    data.http.wait_for_cluster
  ]
}
