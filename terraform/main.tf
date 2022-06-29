module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.1"

  name                 = "k8s-${local.cluster_name}-vpc"
  cidr                 = local.vpc_cidr
  azs                  = local.azs
  private_subnets      = local.vpc_private_subnets
  public_subnets       = local.vpc_public_subnets
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "eks_blueprints" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints?ref=v4.2.0"

  # EKS CLUSTER
  cluster_name       = local.cluster_name
  cluster_version    = "1.22"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  # EKS MANAGED NODE GROUPS
  managed_node_groups = {
    mg_t3 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["t3.small"]
      min_size        = 2
      max_size        = 3
      subnet_ids      = module.vpc.private_subnets
    }
  }
}