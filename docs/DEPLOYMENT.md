# Deployment Reference

## Deploy

```bash
cp examples/general.tfvars terraform.tfvars
terraform init && terraform plan && terraform apply
```

EKS creation takes ~15 minutes.

## Post-apply

```bash
# Connect kubectl
$(terraform output -raw kubeconfig_command)

# Install AWS Load Balancer Controller (required for Ingress to use the ALB)
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$(terraform output -raw cluster_id) \
  --set serviceAccount.create=true

# Install ArgoCD
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace
```

## Tear down

```bash
# Remove Helm releases first
helm uninstall argocd -n argocd
helm uninstall aws-load-balancer-controller -n kube-system
terraform destroy
```
