# =============================================================================
# 03-security-group - PCI-DSS Compliance Profile
# =============================================================================
# No compliance-driven overrides exist for this module today. Kept identical
# to the general profile. Ingress is already restricted to the VPC CIDR only
# (PCI DSS Req 1.3 — restrict inbound/outbound traffic to that necessary for
# the cardholder-data environment), which applies uniformly across profiles.
# =============================================================================

vpc_cidr = "10.0.0.0/16"
