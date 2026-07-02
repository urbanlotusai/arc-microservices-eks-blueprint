# ── Profile: hipaa ────────────────────────────────────────────────────────────
# Activates the HIPAA overlay:
#   - Aurora PITR extended to 35 days + deletion_protection = true
#   - WAF rate limit clamped to 2000 req/IP
#   - Log retention extended to 365 days

environment = "prod"
namespace   = "myorg"

compliance_profile = "hipaa"

# Database
db_password = "CHANGEME-UseSecretsManagerInProd"

# Cluster — larger nodes for HIPAA workloads
node_instance_types = ["m5.xlarge"]
node_desired_size   = 3
node_min_size       = 3
node_max_size       = 10
