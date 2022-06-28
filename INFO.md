# O que será avaliado na sua solução?

* Automação da infra, provisionamento dos hosts (IaaS)

* Automação de setup e configuração dos hosts (IaC)

* Pipeline de deploy automatizado

* Monitoramento dos serviços e métricas da aplicação


# IaaS - Infrastructure as a Service
- AWS

# IaC - Infrastructure as Code
- Terraform
- EKS Blueprints for Terraform

# Managing the Amazon VPC CNI plugin for Kubernetes
- https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html

# Managing the CoreDNS add-on
- https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html

# Managing the kube-proxy add-on
- https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html

# 

terraform destroy -target=""

kubectl logs -n kube-system deployment.apps/aws-load-balancer-controller --follow

aws eks --region us-west-2 update-kubeconfig --name devops-challange


terraform destroy -target="module.eks_blueprints_kubernetes_addons.module.ingress_nginx[0]" -auto-approve
terraform destroy -target="module.eks_blueprints_kubernetes_addons.module.ingress_nginx[0]" -auto-approve && \
terraform destroy -target="module.eks_blueprints_kubernetes_addons.module.aws_load_balancer_controller[0]" -auto-approve && \
terraform destroy -target="module.eks-blueprints-kubernetes-addons" -auto-approve && \
terraform destroy -target="module.eks-blueprints" -auto-approve && \
terraform destroy -auto-approve
terraform destroy -target="module.grafana_prometheus_monitoring" -auto-approve

grafana_prometheus_monitoring


kubectl delete deployment comments && kubectl delete service comments && kubectl delete ingress alb-ingress-host


terraform init
terraform plan
terraform apply -target=module.managed_grafana --auto-approve
terraform apply -target="module.vpc" --auto-approve
terraform apply -target="module.eks_blueprints" --auto-approve
terraform apply -target="module.eks_blueprints_kubernetes_addons" --auto-approve
terraform apply --auto-approve

terraform apply -target="mmodule.eks_blueprints_kubernetes_addons.module.adot_collector_nginx[0]"

SigV4 configuration
