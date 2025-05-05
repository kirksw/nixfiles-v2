
{ pkgs, lib, config, ... }:

{
  options = {
    devops.enable = lib.mkEnableOption "enables devops tooling";
  };

  config = lib.mkIf config.devops.enable {
    home.packages = with pkgs; [
      # IaC
      # terraform
      tenv

      # container/kubernetes
      awscli2
      fluxcd
      docker
      kubectl
      kubelogin
      kubelogin-oidc
      krew
      kubernetes-helm
      argocd 
      k9s
    ];
  };
}
