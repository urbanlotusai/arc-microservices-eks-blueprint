# =============================================================================
# 07-db - PCI-DSS Compliance Profile
# =============================================================================
# Compliance controls enabled:
#   - backup_retention_period = 35 — supports PCI DSS Req 10.5.1 retention of
#     audit-trail history and general data-recovery obligations for the
#     cardholder-data environment.
#   - deletion_protection = true — guards against accidental/malicious loss
#     of cardholder data, aligned with PCI DSS Req 9/12 asset-protection
#     controls.
# =============================================================================

backup_retention_period = 35
deletion_protection     = true
