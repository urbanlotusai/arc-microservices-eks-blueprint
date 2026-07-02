# =============================================================================
# 06-ecr - General Compliance Profile
# =============================================================================
# No compliance-driven overrides exist for this module today — immutable
# tags and scan-on-push are security best practices applied uniformly, not
# profile-specific controls.
# =============================================================================

image_tag_mutability = "IMMUTABLE"
scan_on_push         = true
