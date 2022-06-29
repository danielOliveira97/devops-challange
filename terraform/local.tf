locals {
  cluster_name        = "devops-challange"
  region              = "us-west-2"
  vpc_cidr            = "10.0.0.0/16"
  azs                 = slice(data.aws_availability_zones.available.names, 0, 3)
  vpc_private_subnets = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
  vpc_public_subnets  = ["10.0.12.0/22", "10.0.16.0/22", "10.0.20.0/22"]
  ecr_repository_name = "comments-app"
  github_deploy_user  = "gh_actions_user"
  kubeconfig          = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${module.eks_blueprints.eks_cluster_endpoint}
    certificate-authority-data: ${base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)}
  name: ${local.cluster_name}
contexts:
- context:
    cluster: ${local.cluster_name}
    user: ${local.cluster_name}
  name: ${local.cluster_name}
current-context: ${local.cluster_name}
kind: Config
preferences: {}
users:
- name: ${local.cluster_name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - "${local.cluster_name}"
        - "--region"
        - "${local.region}"
KUBECONFIG

  tags = {
    Cluster = local.cluster_name
  }
}