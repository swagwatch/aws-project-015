#---------------------------------------------------------------
# AWS LOAD BALANCER CONTROLLER IAM ASSUME ROLE POLICY
#---------------------------------------------------------------
data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role_policy" {
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

      values = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    effect = "Allow"
  }
}

#---------------------------------------------------------------
# AWS LOAD BALANCER CONTROLLER IAM POLICY
#---------------------------------------------------------------
resource "aws_iam_policy" "aws_load_balancer_controller_iam_policy" {
  name        = "${var.cluster_name}-aws-load-balancer-controller-iam-policy"
  path        = "/"
  description = "${var.cluster_name}-aws-load-balancer-controller-iam-policy"
  policy      = file("${path.module}/iam/policies/aws-load-balancer-controller/aws-load-balancer-controller.json")
}

#---------------------------------------------------------------
# AWS LOAD BALANCER CONTROLLER IAM ROLE
#---------------------------------------------------------------
resource "aws_iam_role" "aws_load_balancer_controller_role" {
  name               = "aws-load-balancer-controller-irsa-${var.cluster_name}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role_policy.json
}

#---------------------------------------------------------------
# AWS LOAD BALANCER CONTROLLER IAM ROLE POLICY ATTACHMENT
#---------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_policy_attachment" {
  role       = aws_iam_role.aws_load_balancer_controller_role.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller_iam_policy.arn
}

#---------------------------------------------------------------
# AWS LOAD BALANCER CONTROLLER KUBERNETES SERVICE ACCOUNT
#---------------------------------------------------------------
resource "kubernetes_service_account" "aws_load_balancer_controller_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.account_id}:role/aws-load-balancer-controller-irsa-${var.cluster_name}"
    }
  }

  depends_on = [
    module.eks,
    data.http.wait_for_cluster
  ]
}

#---------------------------------------------------------------
# AWS LOAD BALANCER CONTROLLER HELM CHART
#---------------------------------------------------------------
resource "helm_release" "aws_load_balancer_controller" {

  count = local.addon_flag_networking

  name       = "aws-load-balancer-controller"
  chart      = local.helm_dependencies[index(local.helm_dependencies.*.name, "aws-load-balancer-controller")].name
  repository = local.helm_dependencies[index(local.helm_dependencies.*.name, "aws-load-balancer-controller")].repository
  version    = local.helm_dependencies[index(local.helm_dependencies.*.name, "aws-load-balancer-controller")].version
  namespace  = "kube-system"
  atomic     = true

  values = [
    file("${path.module}/helm/aws-load-balancer-controller/aws-load-balancer-controller-values.yaml")
  ]

  set {
    name  = "serviceAccount.create"
    value = "false"
    type  = "auto"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
    type  = "auto"
  }

  set {
    name  = "clusterName"
    value = var.cluster_name
    type  = "auto"
  }

  depends_on = [
    module.eks,
    data.http.wait_for_cluster,
    resource.kubernetes_config_map.custom_error_pages,
    resource.helm_release.nginx-private-ingress
  ]

}
