# =============================================================================
# 06-ecr - PCI-DSS Compliance Profile
# =============================================================================
# No compliance-driven overrides exist for this module today. Kept identical
# to the general profile — scan_on_push already satisfies PCI DSS Req 6.3.2
# (identify vulnerabilities in custom software before deployment).
# =============================================================================

image_tag_mutability = "IMMUTABLE"
scan_on_push         = true
