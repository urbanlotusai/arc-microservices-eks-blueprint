# =============================================================================
# 07-db - General Compliance Profile
# =============================================================================
# Standard 7-day backup retention window and no deletion protection —
# tolerant defaults for non-regulated workloads where the cost of a longer
# PITR window outweighs the recovery benefit.
# =============================================================================

backup_retention_period = 7
deletion_protection     = false
