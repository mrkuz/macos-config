self: super:
{
  kubernetes-helm = super.kubernetes-helm.overrideAttrs (old: {
    doCheck = false;
  });
}
