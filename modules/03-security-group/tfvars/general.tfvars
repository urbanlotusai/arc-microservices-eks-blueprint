# =============================================================================
# 03-security-group - General Compliance Profile
# =============================================================================
# No compliance-driven overrides exist for this module today. vpc_cidr must
# match the cidr_block used by 02-network so ingress rules correctly scope to
# in-VPC traffic.
# =============================================================================

vpc_cidr = "10.0.0.0/16"
