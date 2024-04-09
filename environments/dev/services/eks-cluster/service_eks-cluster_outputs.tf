output "eks_managed_node_groups" {
  value = module.eks-cluster.eks_managed_node_groups
}

output "eks_core_ng_name" {
  value = split(":", module.eks-cluster.eks_managed_node_groups.core-ng.node_group_id)[1]
}

# CLUSTER CNI MIGRATION

# PASS 1
output "addon_migrate_from_vpc_cni_to_cilium_pass_1" {
  value = {
    dev-0001 = {
      addon_enabled = false
    }
  }
}


# PASS 2
output "addon_migrate_from_vpc_cni_to_cilium_pass_2" {
  value = {
    dev-0001 = {
      addon_enabled = false
    }
  }
}


# CLUSTER ADDONS

# STORAGE
output "addon_ebs_csi" {
  value = {
    dev-0001 = {
      addon_enabled = true
    }
  }
}

# NETWORKING
output "addon_cert_manager" {
  value = {
    dev-0001 = {
      addon_enabled = false
    }
  }
}

# INGRESS
output "addon_argocd_app_ingresses" {
  value = {
    dev-0001 = {
      addon_enabled = false
    }
  }
}


# APPLICATION WORKLOAD GITOPS - DEPLOYMENTS - WORKFLOWS - EVENTS
output "addon_argocd_projects" {
  value = {
    dev-0001 = {
      addon_enabled = false
    }
  }
}

output "addon_argocd_apps" {
  value = {
    dev-0001 = {
      addon_enabled = false
    }
  }
}
