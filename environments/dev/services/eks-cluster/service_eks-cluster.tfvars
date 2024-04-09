# service_eks-cluster.tfvars

# EKS MODULE PARAMETERS

# AWS Account Number "XXXXXXXXXXXXX"
account_id = "XXXXXXXXXXXXX"

# VPC ID # "vpc-XXXXXXXXXXXXXXXXXX"
vpc_id = "vpc-XXXXXXXXXXXXXXXXXX"

# VPC CIDR BLOCK
vpc_cidrblock = "10.161.0.0/16"

# Subnet IDS ["subnet-XXXXXXXXXX", "subnet-XXXXXXXXXX", "subnet-XXXXXXXXXX"]
subnet_ids = ["subnet-XXXXXXXXXX", "subnet-XXXXXXXXXX", "subnet-XXXXXXXXXX"]

subnet_ids_as_string = "subnet-XXXXXXXXXX, subnet-XXXXXXXXXX, subnet-XXXXXXXXXX"

cluster_name = "dev-0001"

eks_iam_role_name = "dev-0001"

instance_type = "m5.large"

public_ingress_cert_arn = "arn:aws:acm:us-east-1:XXXXXXXXXXXXX:certificate/XXXXXXXXXXXXX"

kube_namespaces = ["team-black", "team-green", "team-white"]

app_kube_namespaces = ["app-frontend", "app-identity", "app-products", "app-search", "app-orders", "app-payments", "app-reviews"]

# PUBLIC DOMAIN "example.com"
public_domain_filter = "example.com"

# PRIVATE DOMAIN "example.com"
private_domain_filter = "example.com"

# Cert Manager Email admin@example.com
cert_manager_registered_email = "admin@example.com"


# CLUSTER ADDONS

addon_cilium_cni_enabled = false

addon_ekscore_enabled = false

addon_storage_enabled = false

addon_networking_enabled = false

addon_sdlc_enabled = false

addon_monitoring_enabled = false

