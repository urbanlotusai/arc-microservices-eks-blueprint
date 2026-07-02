# =============================================================================
# 02-network - PCI-DSS Compliance Profile
# =============================================================================
# No compliance-driven overrides exist for this module today — VPC CIDR
# sizing is a capacity decision, not a compliance control. Kept identical to
# the general profile. Network segmentation of the cardholder-data
# environment (PCI DSS Req 1.3) is enforced by 03-security-group, not here.
# =============================================================================

cidr_block = "10.0.0.0/16"
