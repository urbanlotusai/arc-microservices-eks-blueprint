# =============================================================================
# 07-db - HIPAA Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - backup_retention_period = 35 — extended point-in-time-recovery window
#     satisfies HIPAA 45 CFR 164.308(a)(7)(ii)(A), which requires a data
#     backup plan capable of restoring ePHI.
#   - deletion_protection = true — prevents accidental/malicious destruction
#     of the cluster holding ePHI, supporting the 164.308(a)(7) contingency
#     plan requirement.
# =============================================================================

backup_retention_period = 35
deletion_protection     = true
