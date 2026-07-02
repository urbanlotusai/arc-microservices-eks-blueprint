# =============================================================================
# 08-cache - General Compliance Profile
# =============================================================================
# No compliance-driven overrides exist for this module today — num_cache_nodes
# and automatic_failover_enabled are hardcoded (2 nodes, failover on) in
# every profile in this blueprint's design; transit and at-rest encryption
# are always on regardless of profile. This mirrors the current single-state
# main.tf, which does not branch this module on compliance_profile.
# =============================================================================

node_type                  = "cache.t3.medium"
num_cache_nodes            = 2
automatic_failover_enabled = true
