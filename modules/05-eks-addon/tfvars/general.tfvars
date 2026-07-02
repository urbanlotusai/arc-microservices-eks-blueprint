# =============================================================================
# 05-eks-addon - General Compliance Profile
# =============================================================================
# No compliance-driven overrides exist for this module today — addon
# versions are an upgrade/compatibility decision, not a compliance control.
# =============================================================================

addons = {
  vpc-cni            = { addon_version = "v1.16.0-eksbuild.1" }
  coredns            = { addon_version = "v1.11.1-eksbuild.4" }
  kube-proxy         = { addon_version = "v1.29.0-eksbuild.1" }
  aws-ebs-csi-driver = { addon_version = "v1.26.0-eksbuild.1" }
}
