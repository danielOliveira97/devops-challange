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

module "eks_blueprints_kubernetes_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.2.0"

  eks_cluster_id       = module.eks_blueprints.eks_cluster_id
  eks_cluster_endpoint = module.eks_blueprints.eks_cluster_endpoint
  eks_oidc_provider    = module.eks_blueprints.oidc_provider
  eks_cluster_version  = module.eks_blueprints.eks_cluster_version

  # EKS Managed Add-ons
  enable_amazon_eks_coredns    = true
  enable_amazon_eks_kube_proxy = true
  enable_amazon_eks_vpc_cni    = true
  enable_amazon_eks_adot      = true

  #K8s Add-ons
  #enable_aws_for_fluentbit            = true
  enable_aws_load_balancer_controller = true
  enable_cluster_autoscaler           = true
  enable_metrics_server               = true

  enable_ingress_nginx = true
  ingress_nginx_helm_config = {
    version = "4.0.17"
    values  = [templatefile("${path.module}/nginx_values.yaml", {})]
  }
}