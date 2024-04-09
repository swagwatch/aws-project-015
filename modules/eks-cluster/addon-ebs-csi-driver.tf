#---------------------------------------------------------------
# AWS EBS CSI DRIVER ASSUME ROLE IAM POLICY
#---------------------------------------------------------------
data "aws_iam_policy_document" "ebs_csi_driver_assume_role_policy" {
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

      values = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    effect = "Allow"
  }
}

#---------------------------------------------------------------
# AWS EBS CSI DRIVER IAM Policy
#---------------------------------------------------------------
resource "aws_iam_policy" "ebs_csi_driver_iam_policy" {
  name        = "${var.cluster_name}-ebs-csi-driver-iam-policy"
  path        = "/"
  description = "${var.cluster_name}-ebs-csi-driver-iam-policy"
  policy      = file("${path.module}/iam/policies/ebs-csi-driver/ebs-csi-driver.json")
}

#---------------------------------------------------------------
# AWS EBS CSI DRIVER IAM ROLE
#---------------------------------------------------------------
resource "aws_iam_role" "ebs_iam_role_for_service_account" {
  name               = "${var.cluster_name}-EBS-CSI-DRIVER-IRSA"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver_assume_role_policy.json
}

#---------------------------------------------------------------
# AWS EBS CSI DRIVER IAM POLICY ATTACHMENT
#---------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "ebs_irsa_policy_attachment" {
  role       = aws_iam_role.ebs_iam_role_for_service_account.name
  policy_arn = aws_iam_policy.ebs_csi_driver_iam_policy.arn
}

#---------------------------------------------------------------
# AWS EBS CSI DRIVER KUBERNETES SERVICE ACCOUNT
#---------------------------------------------------------------
resource "kubernetes_service_account" "ebs_csi_controller_sa" {
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.account_id}:role/${var.cluster_name}-EBS-CSI-DRIVER-IRSA"
    }
  }

  depends_on = [
    module.eks,
    data.http.wait_for_cluster
  ]
}

#---------------------------------------------------------------
# AWS EBS CSI DRIVER HELM CHART
#---------------------------------------------------------------
resource "helm_release" "ebs-csi-driver" {

  count = local.addon_flag_storage

  name       = "ebs-csi-driver"
  chart      = local.helm_dependencies[index(local.helm_dependencies.*.name, "aws-ebs-csi-driver")].name
  repository = local.helm_dependencies[index(local.helm_dependencies.*.name, "aws-ebs-csi-driver")].repository
  version    = local.helm_dependencies[index(local.helm_dependencies.*.name, "aws-ebs-csi-driver")].version
  namespace  = "kube-system"
  atomic     = true

  values = [
    file("${path.module}/helm/ebs-csi-driver/ebs-csi-driver-values.yaml")
  ]

  set {
    name  = "controller.serviceAccount.create"
    value = "false"
    type  = "auto"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "ebs-csi-controller-sa"
    type  = "auto"
  }

  depends_on = [
    module.eks,
    data.http.wait_for_cluster
  ]

}
