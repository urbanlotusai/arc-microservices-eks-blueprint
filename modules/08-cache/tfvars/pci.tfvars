# =============================================================================
# 08-cache - PCI-DSS Compliance Profile
# =============================================================================
# No compliance-driven overrides exist for this module today. Kept identical
# to the general profile — transit and at-rest encryption are always on
# regardless of profile, satisfying PCI DSS Req 4 (encrypt transmission) and
# Req 3 (protect stored data) for any cardholder-data-adjacent cache entries.
# =============================================================================

node_type                  = "cache.t3.medium"
num_cache_nodes            = 2
automatic_failover_enabled = true
