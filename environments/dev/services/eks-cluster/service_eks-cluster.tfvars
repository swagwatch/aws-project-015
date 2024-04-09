# service_eks-cluster.tfvars

# EKS MODULE PARAMETERS

# AWS Account Number "XXXXXXXXXXXXX"
account_id = "092291409865"

# VPC ID # "vpc-XXXXXXXXXXXXXXXXXX"
vpc_id = "vpc-0c2c42df852f77d3a"

# VPC CIDR BLOCK
vpc_cidrblock = "10.161.0.0/16"

# Subnet IDS ["subnet-XXXXXXXXXX", "subnet-XXXXXXXXXX", "subnet-XXXXXXXXXX"]
subnet_ids = ["subnet-0fb80a903f0cea6cb", "subnet-069d595ab4cb6a594", "subnet-01b5ac404fd231316"]

subnet_ids_as_string = "subnet-0fb80a903f0cea6cb, subnet-069d595ab4cb6a594, subnet-01b5ac404fd231316"

cluster_name = "dev-0001"

eks_iam_role_name = "dev-0001"

instance_type = "m5.large"

public_ingress_cert_arn = "arn:aws:acm:us-east-1:092291409865:certificate/bcead709-f832-4635-a8d1-a1f1fa1216c4"

kube_namespaces = ["team-black", "team-green", "team-white"]

app_kube_namespaces = ["app-frontend", "app-identity", "app-products", "app-search", "app-orders", "app-payments", "app-reviews"]

# PUBLIC DOMAIN "example.com"
public_domain_filter = "swagwatch.io"

# PRIVATE DOMAIN "example.com"
private_domain_filter = "swagwatch.io"

# Cert Manager Email admin@example.com
cert_manager_registered_email = "cloud.native.system@gmail.com"


# CLUSTER ADDONS

addon_cilium_cni_enabled = true

addon_ekscore_enabled = true

addon_storage_enabled = true

addon_networking_enabled = false

addon_sdlc_enabled = false

addon_monitoring_enabled = false

