# =============================================================================
# 08-cache - HIPAA Compliance Profile
# =============================================================================
# No compliance-driven overrides exist for this module today. Kept identical
# to the general profile — transit and at-rest encryption are always on
# regardless of profile, which satisfies HIPAA's encryption-in-transit and
# encryption-at-rest expectations for ePHI-adjacent session data.
# =============================================================================

node_type                  = "cache.t3.medium"
num_cache_nodes            = 2
automatic_failover_enabled = true
