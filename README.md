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
| **Compliance-ready** | Built-in `general` / `hipaa` / `pci` profiles activate Aurora PITR, deletion protection, and tighter WAF rate limits. |
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

### 2. Clone

```bash
git clone https://github.com/urbanlotusai/arc-microservices-eks-blueprint.git
cd arc-microservices-eks-blueprint
```

This blueprint uses **independent per-module Terraform state** — there is no root `main.tf`. Each `modules/NN-name/` is applied on its own, with cross-module values (like the KMS key ARN, VPC ID, and cluster ID) resolved via `terraform_remote_state` data sources rather than a parent module.

### 3. Bootstrap the state backend (once per environment)

```bash
make bootstrap ENV=dev REGION=us-east-1 NAMESPACE=myorg
```

Creates the S3 state bucket + DynamoDB lock table every module's backend uses.

### 4. Deploy all modules

```bash
make apply ENV=dev REGION=us-east-1 NAMESPACE=myorg
```

This runs `terraform init` + `apply` across `modules/01-kms` through `modules/11-load-balancer` in order.

### Deploy a single module with a compliance profile

```bash
./scripts/apply-module.sh 07-db dev us-east-1 hipaa
```

Copies `modules/07-db/tfvars/hipaa.tfvars` → `terraform.tfvars` for that module, then inits/plans/applies it alone.

| Step | With `make` (all modules) | Single module |
|---|---|---|
| Validate | `make validate` | `cd modules/<NN-name> && terraform validate` |
| Preview | `make plan` | `./scripts/apply-module.sh <name> <env> <region> <profile>` then inspect the plan |
| Deploy | `make apply` | `./scripts/apply-module.sh <name> <env> <region> <profile>` |

### 5. Configure kubectl and install ArgoCD

```bash
# Update kubeconfig
$(cd modules/04-eks && terraform output -raw cluster_id | xargs -I{} aws eks update-kubeconfig --region us-east-1 --name {})

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

### 6. Push your container image and deploy

```bash
ECR_URL=$(cd modules/06-ecr && terraform output -raw repository_url)
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_URL
docker tag myapp:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

See [sample-app/README.md](sample-app/README.md) for the full build/push/deploy walkthrough, including the Kubernetes manifests.

---

## Compliance profiles

| Profile | Effect |
|---|---|
| `general` | KMS rotation on, 7-day Aurora PITR, WAF rate limit 5000, SQS DLQ retries 3 |
| `hipaa` | Aurora PITR 35 days + deletion protection, WAF rate limit 2000, SQS DLQ retries 1 |
| `pci` | Aurora PITR 35 days + deletion protection, WAF rate limit 1000, SQS DLQ retries 1 |

Apply a profile to any module with `./scripts/apply-module.sh <module> <env> <region> <profile>`.

---

## Key outputs

Each module exposes its own outputs via `terraform output` from within that module's directory:

```bash
cd modules/04-eks    && terraform output cluster_id              # EKS cluster name
cd modules/04-eks    && terraform output cluster_endpoint        # EKS API server endpoint
cd modules/06-ecr    && terraform output repository_url          # push container images here
cd modules/07-db     && terraform output cluster_endpoint        # Aurora writer endpoint
cd modules/08-cache  && terraform output cluster_address         # ElastiCache Redis primary endpoint
cd modules/09-sqs    && terraform output queue_url                # inter-service queue
cd modules/09-sqs    && terraform output dead_letter_queue_url    # dead-letter queue
cd modules/11-load-balancer && terraform output dns_name          # ALB DNS name
cd modules/10-waf    && terraform output arn                     # WAF Web ACL ARN
cd modules/01-kms    && terraform output key_arn                 # CMK
```

---

## Project structure

```
arc-microservices-eks-blueprint/
├── bootstrap/                  # creates the S3 + DynamoDB state backend (apply first)
│   ├── main.tf · variables.tf · outputs.tf
├── modules/                    # each folder is an independent Terraform root
│   ├── 01-kms/
│   │   ├── config.hcl          # static backend key
│   │   ├── main.tf             # own backend "s3" {}, own provider, own module block
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── tfvars/{general,hipaa,pci}.tfvars
│   ├── 02-network/
│   ├── 03-security-group/
│   ├── 04-eks/
│   ├── 05-eks-addon/
│   ├── 06-ecr/
│   ├── 07-db/
│   ├── 08-cache/
│   ├── 09-sqs/
│   ├── 10-waf/
│   └── 11-load-balancer/
├── scripts/
│   └── apply-module.sh         # apply one module with a chosen compliance profile
├── Makefile                    # bootstrap / init / plan / apply / validate / fmt / build-sample
├── .terraform-version          # tfenv pin (1.9.8)
├── sample-app/                 # multi-service Node app + Dockerfile + k8s manifests
├── docs/
│   ├── INSTALL.md              # macOS · Linux · Windows setup guide
│   └── DEPLOYMENT.md           # full deployment + ArgoCD setup + rollback
├── GETTING-STARTED.md          # beginner walkthrough + ArgoCD install
├── CONTRIBUTING.md
├── CHANGELOG.md · LICENSE · NOTICE · VERSION
└── README.md
```

---

## Documentation

- **[GETTING-STARTED.md](GETTING-STARTED.md)** — zero-to-live walkthrough including ArgoCD setup
- **[docs/INSTALL.md](docs/INSTALL.md)** — install Terraform, AWS CLI, kubectl, and Helm on macOS / Linux / Windows
- **[docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)** — full deployment reference, image push, ArgoCD app setup, rollback
- **`modules/*/tfvars/{general,hipaa,pci}.tfvars`** — per-module compliance-profile example files

---

## Important notes

- **Independent per-module state** — there is no root `main.tf` composing all 11 modules. Each `modules/NN-name/` is its own Terraform root with its own S3 backend and provider block. Cross-module values (VPC ID, security group ID, cluster ID, KMS key ARN) are read via `data "terraform_remote_state"` blocks instead of `module.x.output` references.
- **ArgoCD is not a Terraform-managed resource** — there is no `arc-argocd` module, and no Terraform `helm`/`kubernetes` provider is configured anywhere in this blueprint. ArgoCD is installed via the Helm CLI post-apply (Step 5 above), out of band from Terraform. This is the standard GitOps pattern: infrastructure is Terraform, GitOps tooling is Helm.
- **WAF scope is REGIONAL** — this blueprint uses ALB (not CloudFront), so `web_acl_scope = "REGIONAL"`. Do not change it to `CLOUDFRONT`.
- **11-load-balancer must be applied after 05-eks-addon** — the AWS Load Balancer Controller (installed by the VPC CNI addon) must be ready before the ALB is created. In the single-shared-state design this was expressed as `depends_on = [module.eks_addons]`; with independent per-module state there is no parent module to hold that edge, so ordering is achieved purely by applying `modules/` in numeric directory order (`make apply` / `make init` iterate `modules/*/` in sorted order, so `05-eks-addon` always runs before `11-load-balancer`). No `depends_on` exists across module `main.tf` files.
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
