# DevOps Challange

## Environment Modeling
<p align="center">

![image](https://user-images.githubusercontent.com/78129381/153622350-dcaf792f-0704-4426-916a-1551dd9fe8b9.png)

</p>

## Resources and Tools

- **Provider:** AWS
- **IaC:** Terraform
- **Ingress Controler:** Nginx Ingress
- **Container Orchestration Tools and Services:** Kubernetes, EKS and Docker
- **Monitoring:** Grafana and Prometheus

## How to Deploy

### Prerequisites

Ensure that you have installed the following tools in your Mac or Windows Laptop before start working with this module and run Terraform Plan and Apply

1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [Kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### Deployment Steps

#### Step 1: Clone the repo using the command below

```sh
git clone https://github.com/danielOliveira97/devops-challange.git
```

### Step 2: Config environment
* Configure AWS CLI with an user with programmatic access and high privileges
```sh
aws configure
```
* Create s3 bucket for storage tfstate file
  
```sh
aws s3api create-bucket \
    --bucket <enter-bucket-name> \
    --region <enter-your-region>
```
* Update terraform/backend.tf with the AWS S3 bucket name and key name
*  Review terraform variable values in variables.tf, local.tf

#### Step 3: Run Terraform INIT

Initialize a working directory with configuration files

```sh
cd terraform
terraform init
```

#### Step 4: Run Terraform PLAN

Verify the resources created by this execution

```sh
export AWS_REGION=<ENTER YOUR REGION>   # Select your own region
terraform plan
```

#### Step 5: Finally, Terraform APPLY

We will leverage Terraform's [target](https://learn.hashicorp.com/tutorials/terraform/resource-targeting?in=terraform/cli) functionality to deploy a VPC, an EKS Cluster, and Kubernetes add-ons in separate steps.

**Deploy the VPC**. This step will take roughly 3 minutes to complete.

```
terraform apply -target="module.vpc"
```

**Deploy the EKS cluster**. This step will take roughly 14 minutes to complete.

```
terraform apply -target="module.eks_blueprints"
```

**Deploy the add-ons**. This step will take rough 10 minutes to complete.

```
terraform apply -target="module.eks_blueprints_kubernetes_addons"
```

**Deploy all others resources**. This step will take rough 10 minutes to complete.

```
terraform apply --auto-approve
```

### Configure `kubectl` and test cluster

EKS Cluster details can be extracted from terraform output or from AWS Console to get the name of cluster.
This following command used to update the `kubeconfig` in your local machine where you run kubectl commands to interact with your EKS Cluster.

#### Step 5: Run `update-kubeconfig` command

`~/.kube/config` file gets updated with cluster details and certificate from the below command

```sh
    aws eks --region <enter-your-region> update-kubeconfig --name <cluster-name>
```

#### Step 6: List all the worker nodes by running the command below

```sh
    kubectl get nodes
```

#### Step 7: List all the pods running in `ingress-nginx` namespace

```sh
    kubectl get pods -n ingress-nginx
```

## How to Destroy

The following command destroys the resources created by `terraform apply`

```sh
cd terraform

terraform destroy -target="module.eks_blueprints_kubernetes_addons.module.ingress_nginx[0]" -auto-approve

terraform destroy -target="module.eks_blueprints_kubernetes_addons.module.aws_load_balancer_controller[0]" -auto-approve

terraform destroy -target="module.eks-blueprints-kubernetes-addons" -auto-approve

terraform destroy -target="module.eks-blueprints" -auto-approve

terraform destroy -auto-approve
```