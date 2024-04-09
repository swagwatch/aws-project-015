#---------------------------------------------------------------
# AWS EFS CSI DRIVER ASSUME IAM ROLE POLICY
#---------------------------------------------------------------
data "aws_iam_policy_document" "efs_csi_driver_assume_role_policy" {
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

      values = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
    }

    effect = "Allow"
  }
}

#---------------------------------------------------------------
# AWS EFS CSI DRIVER ASSUME IAM POLICY
#---------------------------------------------------------------
resource "aws_iam_policy" "efs_csi_driver_iam_policy" {
  name        = "${var.cluster_name}-efs-csi-driver-iam-policy"
  path        = "/"
  description = "${var.cluster_name}-efs-csi-driver-iam-policy"
  policy      = file("${path.module}/iam/policies/efs-csi-driver/efs-csi-driver.json")
}

#---------------------------------------------------------------
# AWS EFS CSI DRIVER ASSUME IAM ROLE
#---------------------------------------------------------------
resource "aws_iam_role" "efs_iam_role_for_service_account" {
  name               = "${var.cluster_name}-EFS-CSI-DRIVER-IRSA"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.efs_csi_driver_assume_role_policy.json
}

#---------------------------------------------------------------
# AWS EFS CSI DRIVER ASSUME IAM ROLE POLICY ATTACHMENT
#---------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "efs_irsa_policy_attachment" {
  role       = aws_iam_role.efs_iam_role_for_service_account.name
  policy_arn = aws_iam_policy.efs_csi_driver_iam_policy.arn
}

#---------------------------------------------------------------
# EFS CSI DRIVER KUBERNETES SERVICE ACCOUNT
#---------------------------------------------------------------
resource "kubernetes_service_account" "efs_csi_controller_sa" {
  metadata {
    name      = "efs-csi-controller-sa"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.account_id}:role/${var.cluster_name}-EFS-CSI-DRIVER-IRSA"
    }
  }

  depends_on = [
    module.eks,
    data.http.wait_for_cluster
  ]
}

#---------------------------------------------------------------
# AWS EFS CSI DRIVER
#---------------------------------------------------------------
resource "helm_release" "efs-csi-driver" {

  count = local.addon_flag_storage

  name       = "efs-csi-driver"
  chart      = local.helm_dependencies[index(local.helm_dependencies.*.name, "aws-efs-csi-driver")].name
  repository = local.helm_dependencies[index(local.helm_dependencies.*.name, "aws-efs-csi-driver")].repository
  version    = local.helm_dependencies[index(local.helm_dependencies.*.name, "aws-efs-csi-driver")].version
  namespace  = "kube-system"
  atomic     = true

  values = [
    file("${path.module}/helm/efs-csi-driver/efs-csi-driver-values.yaml")
  ]

  set {
    name  = "controller.serviceAccount.create"
    value = "false"
    type  = "auto"
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "efs-csi-controller-sa"
    type  = "auto"
  }

  depends_on = [
    module.eks,
    data.http.wait_for_cluster
  ]

}


#---------------------------------------------------------------
# AWS EFS SECURITY GROUP
#---------------------------------------------------------------
resource "aws_security_group" "efs" {
  name        = "jupyter-hub-efs"
  description = "Allow inbound NFS traffic from private subnets of the VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow NFS 2049/tcp"
    cidr_blocks = [var.vpc_cidrblock]
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
  }
}


#---------------------------------------------------------------
# AWS EFS FILE SYSTEM
#---------------------------------------------------------------
resource "aws_efs_file_system" "efs" {
  creation_token = "efs"
  encrypted      = true

  tags = {
    Name = "${var.cluster_name}-general-efs"
  }

}

#---------------------------------------------------------------
# AWS EFS FILE SYSTEM MOUNT POINTS
#---------------------------------------------------------------
resource "aws_efs_mount_target" "efs_mt" {
  count = length(var.subnet_ids)

  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = element(var.subnet_ids, count.index)
  security_groups = [aws_security_group.efs.id]
}

#---------------------------------------------------------------
# AWS EFS STORAGECLASS
#---------------------------------------------------------------
resource "kubectl_manifest" "aws_efs_storage_class" {

  depends_on = [
    module.eks,
    data.http.wait_for_cluster,
    aws_efs_file_system.efs
  ]

  yaml_body = <<-YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: efs-sc
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: ${aws_efs_file_system.efs.id}
  directoryPerms: "700"
  gidRangeStart: "1000"
  gidRangeEnd: "2000"
YAML

}