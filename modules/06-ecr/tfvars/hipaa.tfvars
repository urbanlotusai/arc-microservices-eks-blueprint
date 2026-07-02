# =============================================================================
# 06-ecr - HIPAA Compliance Profile
# =============================================================================
# No compliance-driven overrides exist for this module today. Kept identical
# to the general profile — immutable tags and scan-on-push already provide
# image-integrity assurance for any workload, regulated or not.
# =============================================================================

image_tag_mutability = "IMMUTABLE"
scan_on_push         = true
