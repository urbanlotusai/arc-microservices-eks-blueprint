.PHONY: help init plan apply validate fmt bootstrap build-sample

# Default target
help:
	@echo "Arc Microservices on EKS Blueprint - Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make init          Initialize all modules (requires bootstrap first)"
	@echo "  make plan          Run terraform plan on all modules"
	@echo "  make apply         Apply all modules in order"
	@echo "  make validate      Validate all Terraform configurations"
	@echo "  make fmt           Format all Terraform files"
	@echo "  make bootstrap     Apply bootstrap module (creates state backend)"
	@echo "  make build-sample  Build the sample app Docker image (prints ECR push steps)"
	@echo ""
	@echo "Variables:"
	@echo "  ENV=dev            Environment (default: dev)"
	@echo "  REGION=us-east-1   AWS region (default: us-east-1)"
	@echo "  NAMESPACE=arc      Namespace prefix (default: arc)"
	@echo "  PROFILE=general    Compliance profile (general|hipaa|pci; default: general)"

# Variables
ENV ?= dev
REGION ?= us-east-1
NAMESPACE ?= arc
STATE_BUCKET = $(NAMESPACE)-$(ENV)-terraform-state
LOCK_TABLE = $(NAMESPACE)-$(ENV)-terraform-locks

# Bootstrap module (uses local state - no config.hcl)
bootstrap:
	@echo "Applying bootstrap..."
	cd bootstrap && terraform init && terraform apply \
		-var="namespace=$(NAMESPACE)" \
		-var="environment=$(ENV)" \
		-var="region=$(REGION)"

# Initialize all modules
init: bootstrap
	@echo "Initializing modules..."
	@for dir in modules/*/; do \
		echo "Initializing $$(basename $$dir)..."; \
		cd $$dir && terraform init -reconfigure \
			-backend-config=config.hcl \
			-backend-config="bucket=$(STATE_BUCKET)" \
			-backend-config="dynamodb_table=$(LOCK_TABLE)" \
			-backend-config="region=$(REGION)" \
			|| exit 1; \
		cd - > /dev/null; \
	done

# Plan all modules
plan: init
	@echo "Planning all modules..."
	@for dir in modules/*/; do \
		echo "Planning $$(basename $$dir)..."; \
		cd $$dir && terraform plan \
			-var="state_bucket_name=$(STATE_BUCKET)" \
			-var="namespace=$(NAMESPACE)" \
			-var="environment=$(ENV)" \
			-var="region=$(REGION)" \
			|| exit 1; \
		cd - > /dev/null; \
	done

# Apply all modules in order
apply: init
	@echo "Applying all modules..."
	@for dir in modules/*/; do \
		echo "Applying $$(basename $$dir)..."; \
		cd $$dir && terraform apply -auto-approve \
			-var="state_bucket_name=$(STATE_BUCKET)" \
			-var="namespace=$(NAMESPACE)" \
			-var="environment=$(ENV)" \
			-var="region=$(REGION)" \
			|| exit 1; \
		cd - > /dev/null; \
	done

# Validate all modules
validate:
	@echo "Validating all modules..."
	@for dir in bootstrap modules/*/; do \
		echo "Validating $$(basename $$dir)..."; \
		cd $$dir && terraform validate || exit 1; \
		cd - > /dev/null; \
	done

# Format all Terraform files
fmt:
	@echo "Formatting Terraform files..."
	@find . -name "*.tf" -exec terraform fmt {} \;

# Build the sample app Docker image (push commands require the ECR URL from
# the 06-ecr module output, so they are printed rather than run automatically)
build-sample:
	@echo "Building sample-app Docker image..."
	@docker build -t $(NAMESPACE)-$(ENV)-app:latest sample-app/
	@echo ""
	@echo "Image built: $(NAMESPACE)-$(ENV)-app:latest"
	@echo "Push it to ECR:"
	@echo "  ECR_URL=\$$(cd modules/06-ecr && terraform output -raw repository_url)"
	@echo "  aws ecr get-login-password | docker login --username AWS --password-stdin \$$ECR_URL"
	@echo "  docker tag $(NAMESPACE)-$(ENV)-app:latest \$$ECR_URL:latest"
	@echo "  docker push \$$ECR_URL:latest"
