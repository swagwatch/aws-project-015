#

module "eks-cluster" {

  source = "../../modules/eks-cluster"

  account_id = var.account_id

  vpc_id = var.vpc_id

  vpc_cidrblock = var.vpc_cidrblock

  subnet_ids = var.subnet_ids

  subnet_ids_as_string = var.subnet_ids_as_string

  cluster_name = var.cluster_name

  eks_iam_role_name = var.eks_iam_role_name

  instance_type = var.instance_type

  public_enabled = true

  public_ingress_cert_arn = var.public_ingress_cert_arn

  kube_namespaces = var.kube_namespaces

  app_kube_namespaces = var.app_kube_namespaces

  public_domain_filter = var.public_domain_filter

  private_domain_filter = var.private_domain_filter

  cert_manager_registered_email = var.cert_manager_registered_email

  addon_cilium_cni_enabled = var.addon_cilium_cni_enabled

  addon_ekscore_enabled = var.addon_ekscore_enabled

  addon_storage_enabled = var.addon_storage_enabled

  addon_networking_enabled = var.addon_networking_enabled

  addon_sdlc_enabled = var.addon_sdlc_enabled

  addon_monitoring_enabled = var.addon_monitoring_enabled

}
