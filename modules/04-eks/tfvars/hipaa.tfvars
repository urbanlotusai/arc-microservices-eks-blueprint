# =============================================================================
# 04-eks - HIPAA Compliance Profile
# =============================================================================
# No compliance-driven overrides exist for this module today. Kept identical
# to the general profile — Kubernetes Secrets are always encrypted with the
# 01-kms CMK regardless of profile, which satisfies HIPAA's 45 CFR
# 164.312(a)(2)(iv) encryption-at-rest requirement for ePHI-adjacent secrets.
# =============================================================================

kubernetes_version   = "1.29"
node_instance_types  = ["m5.xlarge"]
node_desired_size    = 3
node_min_size        = 2
node_max_size        = 10
