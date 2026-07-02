# =============================================================================
# 10-waf - General Compliance Profile
# =============================================================================
# Standard rate limit of 5000 requests per 5 minutes per IP — permissive
# enough for typical non-regulated public traffic while still blocking
# obvious abuse.
# =============================================================================

waf_rate_limit = 5000
