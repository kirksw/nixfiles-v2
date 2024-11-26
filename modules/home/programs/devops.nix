
{ pkgs, lib, config, ... }:

{
  options = {
    devops.enable = lib.mkEnableOption "enables devops tooling";
  };

  config = lib.mkIf config.devops.enable {
    home.packages = with pkgs; [
      # terraform
      tenv

      # container/kubernetes
      docker
      kubectl
      krew
      kubernetes-helm
      argocd 
      k9s
    ];
  };
}
