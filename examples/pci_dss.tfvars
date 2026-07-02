# ── Profile: pci_dss ──────────────────────────────────────────────────────────
# Activates the PCI DSS overlay:
#   - Aurora PITR 35 days + deletion_protection = true
#   - SQS DLQ max retries = 1
#   - WAF rate limit clamped to 1000 req/IP
#   - Log retention 365 days

environment = "prod"
namespace   = "myorg"

compliance_profile = "pci_dss"

db_password = "CHANGEME-UseSecretsManagerInProd"

# PCI DSS: larger nodes for CDE isolation
node_instance_types = ["m5.xlarge"]
node_desired_size   = 3
node_min_size       = 3
node_max_size       = 10
