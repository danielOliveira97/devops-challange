locals {
  cluster_name        = "devops-challange"
  region              = "us-west-2"
  vpc_cidr            = "10.0.0.0/16"
  azs                 = slice(data.aws_availability_zones.available.names, 0, 3)
  vpc_private_subnets = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
  vpc_public_subnets  = ["10.0.12.0/22", "10.0.16.0/22", "10.0.20.0/22"]

  tags = {
    Cluster = local.cluster_name
  }
}