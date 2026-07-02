# Sample App

A **zero-dependency Node.js HTTP service** that proves the microservices EKS stack works end-to-end with no code of your own.

```
ALB → EKS Ingress → platform namespace → this pod → Aurora / Redis / SQS
```

Replace `index.js` with your real service whenever you are ready.

---

## What it returns

`GET /` → JSON welcome payload including the wired `DB_HOST`, `REDIS_HOST`, and `SQS_QUEUE` env vars.
`GET /health` → `{ "status": "ok" }`.

## Test locally

```bash
cd sample-app
node index.js          # starts on :8080
curl http://localhost:8080/health
```

## Build and push to ECR

From the blueprint root (after `terraform apply`):

```bash
ECR_URL=$(terraform output -raw ecr_repository_url)
aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_URL

docker build -t $ECR_URL:latest sample-app/
docker push $ECR_URL:latest
```

## Deploy to EKS

```bash
$(terraform output -raw kubeconfig_command)

# Replace the image and backing-service endpoints in deployment.yaml
sed -i "s|REPLACE_WITH_ECR_URL|$ECR_URL|g" sample-app/k8s/deployment.yaml
sed -i "s|REPLACE_WITH_DB_ENDPOINT|$(terraform output -raw db_cluster_endpoint)|g" sample-app/k8s/deployment.yaml
sed -i "s|REPLACE_WITH_REDIS_ENDPOINT|$(terraform output -raw cache_cluster_address)|g" sample-app/k8s/deployment.yaml
sed -i "s|REPLACE_WITH_SQS_URL|$(terraform output -raw sqs_queue_url)|g" sample-app/k8s/deployment.yaml

kubectl apply -f sample-app/k8s/namespace.yaml
kubectl apply -f sample-app/k8s/deployment.yaml
kubectl apply -f sample-app/k8s/service.yaml

# Verify
kubectl get pods -n sample-tenant
kubectl logs -n sample-tenant -l app=sample-app
```

## Order of operations

1. `terraform apply` — creates cluster, ECR, Aurora, Redis, SQS, ALB
2. Build + push image to ECR
3. Update kubeconfig
4. `kubectl apply` the k8s manifests
5. Verify pods are Running and `/health` returns 200

---

Built by **[SourceFuse](https://www.sourcefuse.com)**.
