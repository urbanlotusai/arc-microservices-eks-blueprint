# =============================================================================
# 03-security-group - HIPAA Compliance Profile
# =============================================================================
# No compliance-driven overrides exist for this module today. Kept identical
# to the general profile — HIPAA network-segmentation guidance is satisfied
# by scoping ingress to the VPC CIDR only, which applies uniformly here.
# =============================================================================

vpc_cidr = "10.0.0.0/16"
