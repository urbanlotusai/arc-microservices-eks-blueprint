# =============================================================================
# 04-eks - General Compliance Profile
# =============================================================================
# No compliance-driven overrides exist for this module today — node sizing
# and Kubernetes version are capacity/upgrade decisions, not compliance
# controls. Secrets encryption (via the 01-kms CMK) is always on regardless
# of profile.
# =============================================================================

kubernetes_version   = "1.29"
node_instance_types  = ["m5.xlarge"]
node_desired_size    = 3
node_min_size        = 2
node_max_size        = 10
