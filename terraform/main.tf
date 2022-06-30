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
  enable_amazon_eks_adot       = true

  # K8s Add-ons
  #enable_aws_for_fluentbit            = true
  enable_aws_load_balancer_controller = true
  enable_cluster_autoscaler           = true
  enable_metrics_server               = true

  # NGINX INGRESS CONTROLLER 
  enable_ingress_nginx = true
  ingress_nginx_helm_config = {
    version = "4.0.17"
    values  = [templatefile("${path.module}/nginx_values.yaml", {})]
  }
}

resource "aws_ecr_repository" "app_repository_image" {
  name                 = local.ecr_repository_name
  image_tag_mutability = var.immutable_ecr_repositories ? "IMMUTABLE" : "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

module "iam_policy" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-policy"
  name        = "github-ecr-policy"
  path        = "/"
  description = "Policy for github actions pipelines"
  policy      = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AllowPush",
      "Effect":"Allow",
      "Action":[
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
      ],
      "Resource": "${data.aws_ecr_repository.service.arn}"
    }
  ]
}
EOF
}

module "iam_user" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-user"
  name                          = local.github_deploy_user
  create_iam_user_login_profile = false
  create_iam_access_key         = true
}

module "iam_group_with_policies" {
  source                            = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  name                              = "github-actions"
  group_users                       = ["${module.iam_user.iam_user_name}"]
  attach_iam_self_management_policy = true
  custom_group_policy_arns = [
    "${module.iam_policy.arn}",
  ]
}

resource "github_actions_secret" "gh_secret_aws_access_key_id" {
  repository      = var.app_github_repository
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = var.gh_secret_aws_access_key_id
}

resource "github_actions_secret" "gh_secret_aws_secret_access_key" {
  repository      = var.app_github_repository
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = var.gh_secret_aws_secret_access_key
}

resource "github_actions_secret" "gh_secret_aws_region" {
  repository      = var.app_github_repository
  secret_name     = "AWS_REGION"
  plaintext_value = local.region
}

resource "github_actions_secret" "gh_secret_kube_config_data" {
  repository      = var.app_github_repository
  secret_name     = "KUBE_CONFIG_DATA"
  plaintext_value = base64encode(local.kubeconfig)
}

resource "github_actions_secret" "gh_secret_ecr_repository" {
  repository      = var.app_github_repository
  secret_name     = "ECR_REPOSITORY"
  plaintext_value = data.aws_ecr_repository.service.repository_url
}

resource "github_actions_secret" "gh_secret_eks_cluster_name" {
  repository      = var.app_github_repository
  secret_name     = "EKS_CLUSTER_NAME"
  plaintext_value = module.eks_blueprints.eks_cluster_id
}
