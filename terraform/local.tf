locals {
  cluster_name        = "devops-challange"
  region              = "us-west-2"
  vpc_cidr            = "10.0.0.0/16"
  azs                 = slice(data.aws_availability_zones.available.names, 0, 3)
  vpc_private_subnets = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
  vpc_public_subnets  = ["10.0.12.0/22", "10.0.16.0/22", "10.0.20.0/22"]
  ecr_repository_name = "comments-app"
  github_deploy_user  = "gh_actions_user"
  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    clusters = [{
      name = module.eks_blueprints.eks_cluster_id
      cluster = {
        certificate-authority-data = module.eks_blueprints.eks_cluster_certificate_authority_data
        server                     = module.eks_blueprints.eks_cluster_endpoint
      }
    }]
    contexts = [{
      name = data.aws_eks_cluster.cluster.arn
      context = {
        cluster = data.aws_eks_cluster.cluster.arn
        user    = data.aws_eks_cluster.cluster.arn
      }
    }]
    current-context =  data.aws_eks_cluster.cluster.arn
    preferences: {}
    users = [{
      name = data.aws_eks_cluster.cluster.arn
      user = {
        exec = {
          apiVersion = "client.authentication.k8s.io/v1alpha1"
          args        = ["--region","${local.region}","eks", "get-token", "--cluster-name", "${local.cluster_name}"]
          command     = "aws"
        }
      }
    }]
  })

  tags = {
    Cluster = local.cluster_name
  }
}