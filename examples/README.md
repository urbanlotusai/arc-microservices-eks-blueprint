# Examples

| File | Description |
|---|---|
| `general.tfvars` | Standard EKS microservices platform |

Copy to `../terraform.tfvars` before running `terraform plan`.
After deploy, install ArgoCD via Helm for GitOps:
```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace
```
