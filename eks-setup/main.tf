output "vpc" {
  value = module.vpc.private_subnets
}

locals {
  eks_workload_subnet_ids = [for k, v in module.vpc.private_subnets : v["id"] if startswith(k, "workload")]
  name                    = "my-eks"
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  create = var.create_vpc

  name = local.name

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = local.eks_workload_subnet_ids
  control_plane_subnet_ids = local.eks_workload_subnet_ids

  cloudwatch_log_group_retention_in_days = 30

  kubernetes_version = "1.35"

  endpoint_private_access = true
  endpoint_public_access  = true

  enable_irsa = true

  enable_cluster_creator_admin_permissions = true

  compute_config = {
    enabled = false
  }

  # enable all logs
  enabled_log_types = [
    "audit",
    "api",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  create_node_iam_role       = false
  create_node_security_group = false

  addons = {
    coredns    = {}
    kube-proxy = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    vpc-cni = {
      before_compute = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }


  eks_managed_node_groups = {
    karpenter = {
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["m5.large"]

      min_size     = 2
      max_size     = 3
      desired_size = 2

      # iam_role_additional_policies = []  

      labels = {
        # Used to ensure Karpenter runs on nodes that it does not manage
        "karpenter.sh/controller" = "true"
      }
    }
  }
  // TODO: check how to pass roles to nodes, also with karpenter


  node_security_group_tags = {
    "karpenter.sh/discovery" = local.name
  }
}
