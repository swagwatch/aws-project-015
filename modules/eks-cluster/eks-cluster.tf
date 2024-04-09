# eks-cluster.tf

locals {
  cluster_name = var.cluster_name
  partition    = data.aws_partition.current.partition
}

module "eks" {
  source = "github.com/terraform-aws-modules/terraform-aws-eks?ref=v19.15.3"

  vpc_id                          = var.vpc_id
  subnet_ids                      = var.subnet_ids
  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_enabled_log_types       = var.cluster_enabled_log_types
  cluster_endpoint_private_access = var.cluster_endpoint_private_access
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    iam_role_attach_cni_policy = true
    instance_types             = [var.instance_type]
  }

  eks_managed_node_groups = {
    core-ng = {

      name = "core-ng"

      description = "EKS Core Node Group for hosting system add-ons"

      labels = {
        node-group = "core-ng"
        intent     = "general"
        workload   = "general"
      }

      min_size      = var.node_min_size
      max_size      = var.node_max_size
      desired_size  = var.node_min_size
      ebs_optimized = true
      iam_role_name = "${local.iam_role_name}-core-ng"

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            delete_on_termination = true
            encrypted             = true
            iops                  = 3000
            throughput            = 250
            volume_size           = 150
            volume_type           = "gp3"
            kms_key_arn           = aws_kms_key.ebs.arn
          }
        }
      }

      capacity_type   = "ON_DEMAND"
      use_name_prefix = true
      ami_type        = "AL2_x86_64"

      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 2
        instance_metadata_tags      = "disabled"
      }

      update_config = {
        max_unavailable_percentage = 50
      }

      tags = {
        Name                     = "${var.cluster_name}-general",
        "karpenter.sh/discovery" = var.cluster_name
      }

      # ONLY APPLY THIS TAINT IF USING CILIUM CNI
      taints = {
        cilium = {
          key    = "node.cilium.io/agent-not-ready"
          value  = "true"
          effect = "NO_EXECUTE"
        }
      }

    }
  }

  manage_aws_auth_configmap = true

  node_security_group_additional_rules = {
    # Extend node-to-node security group rules. Recommended and required for EKS Add-ons
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    # Recommended outbound traffic for Node groups
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
    # Allows Control Plane Nodes to talk to Worker nodes on all ports.
    ingress_cluster_to_node_all_traffic = {
      description                   = "Cluster API to Nodegroup all traffic"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
    # Allows all traffic from ALBs to reach the nodes
    ingress_alb_traffic = {
      description              = "Allows all traffic from ALBs to reach the nodes"
      protocol                 = "tcp"
      from_port                = 0
      to_port                  = 0
      type                     = "ingress"
      source_security_group_id = aws_security_group.alb.id
    }
  }

}


# Allow EKS Control Plane to become available before applying k8s resources or helm charts
data "http" "wait_for_cluster" {
  url            = format("%s/healthz", module.eks.cluster_endpoint)
  ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  timeout        = 300
  depends_on = [
    module.eks
  ]
}


# AWS production ready EKS module addons
# https://github.com/aws-ia/terraform-aws-eks-blueprints
module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.32.1"

  count = local.addon_flag_ekscore

  eks_cluster_id = var.cluster_name

  # K8s Add-ons
  enable_cluster_autoscaler = true
  cluster_autoscaler_helm_config = {
    values = [templatefile("${path.module}/helm/cluster-autoscaler/custom-autoscaler-values.yaml", {
      image_tag      = "v1.26.2"
      eks_cluster_id = var.cluster_name
      aws_region     = data.aws_region.current.name
    })]
  }

  enable_metrics_server = true

  tags = {
    Terraform = "true"
  }

  depends_on = [
    module.eks,
    data.http.wait_for_cluster
  ]
}

