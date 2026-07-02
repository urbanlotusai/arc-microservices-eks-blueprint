# =============================================================================
# 11-load-balancer - General Compliance Profile
# =============================================================================
# No compliance-driven overrides exist for this module today — this module
# has no variables beyond the universal namespace/environment/region/tags/
# state_bucket_name. The ALB is always internet-facing HTTP:80 with a
# fixed-response default action; WAF association and rate limiting live in
# 10-waf.
# =============================================================================
