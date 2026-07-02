<div align="center">

# ARC Microservices on EKS Blueprint

### Production microservices platform on EKS — in one `terraform apply`

**A SourceFuse ARC Blueprint**

![Version](https://img.shields.io/badge/version-1.0.0-E8392A)
![License](https://img.shields.io/badge/license-Apache--2.0-1A1A2E)
![Terraform](https://img.shields.io/badge/terraform-%3E%3D1.3-7B42BC)
![AWS Provider](https://img.shields.io/badge/aws--provider-%3E%3D5.0-FF9900)
![ARC Modules](https://img.shields.io/badge/ARC%20modules-11-E8392A)

</div>

---

## What is this?

A **ready-to-deploy Terraform blueprint** that wires a complete microservices platform on
Amazon EKS using **11 [SourceFuse ARC](https://registry.terraform.io/namespaces/modules/sourcefuse) modules**.
One `terraform apply` gives you:

- **EKS cluster** with managed node groups, encrypted secrets (KMS CMK)
- **AWS EKS Addons**: VPC CNI, CoreDNS, kube-proxy, EBS CSI Driver
- **Aurora PostgreSQL** (KMS-encrypted, PITR on strict profiles)
- **ElastiCache Redis** (encrypted in-transit + at-rest)
- **SQS** inter-service queue with built-in DLQ
- **ECR** container registry (immutable tags, scan-on-push)
- **ALB + WAF** (REGIONAL Web ACL with rate limiting)
- **ArgoCD** GitOps — deployed post-apply via Helm (see GETTING-STARTED.md)

No hand-wiring of VPCs, IAM roles for service accounts, ALB ingress controllers, or WAF scopes. The hard, error-prone parts are already solved and pinned.

---

## Why use this blueprint?

| Advantage | What it means for you |
|---|---|
| **Minutes, not days** | A complete, secured EKS microservices stack normally takes days of Terraform wiring — this deploys in one command. |
| **Secure by default** | KMS CMK encrypts EKS secrets, Aurora, Redis, and SQS. ECR images scanned on push. WAF rate-limits ingress. |
| **Compliance-ready** | Built-in `general` / `hipaa` profiles activate Aurora PITR, deletion protection, and tighter WAF rate limits. |
| **Proven building blocks** | Every resource comes from a published, versioned SourceFuse ARC module. Upgrades are a version bump. |
| **GitOps-ready** | ArgoCD is deployed post-apply via Helm. Point it at your app repo and all future deployments are pull-based. |
| **Portable & auditable** | Pure Terraform. Version-controlled, reproducible across environments and accounts. |
| **Beginner-friendly** | One `Makefile`, copy-paste examples per profile, and step-by-step docs for macOS, Linux, and Windows. |

---

## Architecture

```
  Internet
      │
  ┌──────────────────────────────┐
  │  ALB  ←→  WAF (REGIONAL)    │
  └──────────────────────────────┘
      │
  EKS Cluster (managed node groups)
  ├── Service A pod
  ├── Service B pod               ECR
  └── Service C pod  ←────────── (container images)
       │         │         │
  Aurora DB   Redis      SQS Queue
  (KMS enc.) (KMS enc.)  (+ DLQ)

  ArgoCD → GitOps deployments (post-apply Helm install)
  └── KMS CMK ── EKS secrets · Aurora · Redis · SQS
```

---

## The 11 ARC modules

| Module | Version | Role |
|---|---|---|
| [arc-kms](https://registry.terraform.io/modules/sourcefuse/arc-kms/aws) | 1.0.11 | Customer Managed Key — root of the encryption trust chain |
| [arc-network](https://registry.terraform.io/modules/sourcefuse/arc-network/aws) | 3.0.14 | VPC + public/private subnets |
| [arc-security-group](https://registry.terraform.io/modules/sourcefuse/arc-security-group/aws) | 0.0.5 | Cluster and DB access control |
| [arc-eks](https://registry.terraform.io/modules/sourcefuse/arc-eks/aws) | 6.0.4 | EKS cluster + managed node groups |
| [arc-eks-addon](https://registry.terraform.io/modules/sourcefuse/arc-eks-addon/aws) | 1.0.3 | VPC CNI, CoreDNS, kube-proxy, EBS CSI |
| [arc-ecr](https://registry.terraform.io/modules/sourcefuse/arc-ecr/aws) | 0.0.4 | Container registry (immutable, scan-on-push) |
| [arc-db](https://registry.terraform.io/modules/sourcefuse/arc-db/aws) | 4.0.4 | Aurora PostgreSQL cluster |
| [arc-cache](https://registry.terraform.io/modules/sourcefuse/arc-cache/aws) | 0.0.7 | ElastiCache Redis (encrypted at rest + in transit) |
| [arc-sqs](https://registry.terraform.io/modules/sourcefuse/arc-sqs/aws) | 0.0.3 | Inter-service queue + DLQ |
| [arc-waf](https://registry.terraform.io/modules/sourcefuse/arc-waf/aws) | 1.0.6 | REGIONAL Web ACL — attached to ALB |
| [arc-load-balancer](https://registry.terraform.io/modules/sourcefuse/arc-load-balancer/aws) | 0.0.3 | Application Load Balancer |

---

## Quick start

### 1. Prerequisites

- **Terraform** `>= 1.3` ([install guide](docs/INSTALL.md))
- **AWS credentials** configured (`aws configure`)
- **kubectl** installed ([install guide](https://kubernetes.io/docs/tasks/tools/))
- **Helm** `>= 3.x` (for post-apply ArgoCD install)

### 2. Configure

```bash
git clone https://github.com/sourcefuse/arc-microservices-eks-blueprint.git
cd arc-microservices-eks-blueprint

cp examples/general.tfvars terraform.tfvars
```

Edit the mandatory values in `terraform.tfvars`:

| Variable | Example |
|---|---|
| `environment` | `prod` |
| `namespace` | `myorg` |
| `db_password` | `YourSecureDBPassword` |

### 3. Deploy

| Step | With `make` | Raw Terraform (all OS) |
|---|---|---|
| Validate | `make validate` | `terraform init -backend=false && terraform validate` |
| Preview | `make plan` | `terraform plan` |
| Deploy | `make apply` | `terraform init && terraform apply` |

### 4. Configure kubectl and install ArgoCD

```bash
# Update kubeconfig
$(terraform output -raw kubeconfig_command)

# Install ArgoCD via Helm (post-apply step — no arc-argocd module needed)
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --set server.service.type=LoadBalancer

# Get the ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

### 5. Push your container image and deploy

```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_URL
docker tag myapp:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

---

## Compliance profiles

| Profile | Effect |
|---|---|
| `general` | KMS rotation on, 7-day Aurora PITR, WAF rate limit 5000 |
| `hipaa` | Aurora PITR 35 days + deletion protection, WAF rate limit 2000 |

---

## Key outputs

```bash
terraform output cluster_id             # EKS cluster name
terraform output cluster_endpoint       # EKS API server endpoint
terraform output kubeconfig_command     # aws eks update-kubeconfig ...
terraform output ecr_repository_url     # push container images here
terraform output db_cluster_endpoint    # Aurora writer endpoint
terraform output redis_endpoint         # ElastiCache primary endpoint
terraform output sqs_queue_url          # inter-service queue
terraform output sqs_dlq_url            # dead-letter queue
terraform output alb_dns_name           # ALB DNS name
terraform output waf_arn                # WAF Web ACL ARN
terraform output kms_key_arn            # CMK
```

---

## Project structure

```
arc-microservices-eks-blueprint/
├── main.tf                   # 11 ARC module blocks, in dependency order
├── variables.tf              # all inputs with types & descriptions
├── locals.tf                 # naming, tags, compliance overlays
├── data.tf                   # caller identity, KMS policy, subnet lookups, EKS auth
├── outputs.tf                # cluster ID, ECR URL, Aurora/Redis endpoints, queue URLs
├── version.tf                # Terraform + AWS + kubernetes + helm provider pins
├── terraform.tfvars.example  # copy to terraform.tfvars
├── examples/
│   ├── README.md
│   ├── general.tfvars
│   └── hipaa.tfvars
├── docs/
│   ├── INSTALL.md            # macOS · Linux · Windows setup guide
│   └── DEPLOYMENT.md        # full deployment + ArgoCD setup + rollback
├── GETTING-STARTED.md        # beginner walkthrough + ArgoCD install
├── CONTRIBUTING.md
├── CHANGELOG.md · LICENSE · NOTICE · Makefile · VERSION
└── README.md
```

---

## Documentation

- **[GETTING-STARTED.md](GETTING-STARTED.md)** — zero-to-live walkthrough including ArgoCD setup
- **[docs/INSTALL.md](docs/INSTALL.md)** — install Terraform, AWS CLI, kubectl, and Helm on macOS / Linux / Windows
- **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** — full deployment reference, image push, ArgoCD app setup, rollback
- **[examples/README.md](examples/README.md)** — compliance-profile example files

---

## Important notes

- **ArgoCD is not a Terraform-managed resource** — there is no `arc-argocd` module. ArgoCD is installed via Helm post-apply (Step 4 above). This is the standard GitOps pattern: infrastructure is Terraform, GitOps tooling is Helm.
- **WAF scope is REGIONAL** — this blueprint uses ALB (not CloudFront), so `web_acl_scope = "REGIONAL"`. Do not change it to `CLOUDFRONT`.
- **Two providers need EKS to exist** — the `kubernetes` and `helm` providers reference `module.eks` outputs. They cannot configure until after the first apply. This is expected.
- **ALB depends on EKS addons** — `module.alb` has `depends_on = [module.eks_addons]` because the AWS Load Balancer Controller (installed by the VPC CNI addon) must be ready before the ALB is created.
- **Two-apply KMS pattern** — narrow the KMS key policy after first apply to grant only the EKS node role and ECS task role. See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md).

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Apache License 2.0 — see [LICENSE](LICENSE) and [NOTICE](NOTICE).

---

<div align="center">

### Built by [SourceFuse](https://www.sourcefuse.com)

Part of the **ARC** (Accelerated Reference Cloud) blueprint family.
Explore all ARC modules on the [Terraform Registry](https://registry.terraform.io/namespaces/modules/sourcefuse).

</div>
