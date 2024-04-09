# variables.tf

variable "account_id" {
  description = "AWS account ID where cluster will be deployed"
  type        = string
}

variable "vpc_id" {
  description = ""
  type        = string
}

variable "vpc_cidrblock" {
  description = "value"
  type        = string
}

variable "subnet_ids" {
  description = ""
  type        = list(string)
}

variable "subnet_ids_as_string" {
  description = ""
  type        = string
}

variable "cluster_name" {
  description = ""
  type        = string
}

variable "eks_iam_role_name" {
  description = ""
  type        = string
}

variable "cluster_version" {
  description = ""
  type        = string
  default     = "1.26"
}

variable "cluster_enabled_log_types" {
  description = ""
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_endpoint_private_access" {
  description = ""
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = ""
  type        = bool
  default     = true
}

variable "instance_type" {
  description = ""
  type        = string
}

variable "node_min_size" {
  description = ""
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = ""
  type        = number
  default     = 50
}

variable "tags" {
  description = ""
  type        = list(string)
  default     = [""]
}

variable "public_enabled" {
  default = false
}

variable "public_ingress_cert_arn" {
  default = ""
  type    = string
}

variable "kube_namespaces" {
  description = "Kubernetes Application Namespaces"
  type        = list(string)
}

variable "app_kube_namespaces" {
  description = "Kubernetes Application Namespaces With Service Mesh"
  type        = list(string)
}

variable "helm_defaults" {
  description = "Customize default Helm Behavior"
  type        = any
  default     = {}
}

variable "public_domain_filter" {
  description = "Public AWS ROUTE 53 ZONE"
  type        = string
}

variable "private_domain_filter" {
  description = "Private AWS ROUTE 53 ZONE"
  type        = string
}

variable "cert_manager_registered_email" {
  description = "Registered Email For Cert Manager"
  type        = string
}


# CILIUM CNI ADDON
variable "addon_cilium_cni_enabled" {
  description = "Cilium eBPF CNI"
  type        = bool
}


# EKS CORE ADDONs
variable "addon_ekscore_enabled" {
  description = "Cluster AutoScaler and Metrics Server"
  type        = bool
}


# STORAGE ADDONS
variable "addon_storage_enabled" {
  description = "EKS Cluster Storage Related Addons"
  type        = bool
}

# NETWORKING ADDONS
variable "addon_networking_enabled" {
  description = "EKS Cluster Networking Related Addons"
  type        = bool
}

# APPLICATION LIFE CYCLE ADDONS
variable "addon_sdlc_enabled" {
  description = "GitOps Addons"
  type        = bool
}

# MONITORING ADDONS
variable "addon_monitoring_enabled" {
  description = "Cluster Monitoring Addons"
  type        = bool
}

