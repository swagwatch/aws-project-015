data "aws_region" "current" {}

data "aws_partition" "current" {}

data "aws_ami" "eks_node_cpu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_ami" "eks_node_gpu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-gpu-node-${var.cluster_version}*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
