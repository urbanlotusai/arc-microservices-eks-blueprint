# Getting Started

See **[docs/INSTALL.md](docs/INSTALL.md)** for tool installation.

```bash
cp examples/general.tfvars terraform.tfvars
terraform init && terraform apply
$(terraform output -raw kubeconfig_command)
kubectl get nodes
```

Install ArgoCD for GitOps (post-apply):
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace
kubectl port-forward svc/argocd-server 8080:443 -n argocd
# Open https://localhost:8080
```
