# =============================================================================
# 05-eks-addon - HIPAA Compliance Profile
# =============================================================================
# No compliance-driven overrides exist for this module today. Kept identical
# to the general profile.
# =============================================================================

addons = {
  vpc-cni            = { addon_version = "v1.16.0-eksbuild.1" }
  coredns            = { addon_version = "v1.11.1-eksbuild.4" }
  kube-proxy         = { addon_version = "v1.29.0-eksbuild.1" }
  aws-ebs-csi-driver = { addon_version = "v1.26.0-eksbuild.1" }
}
