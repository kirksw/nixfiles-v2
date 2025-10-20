{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:

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
      kubectl-slice
      kubelogin-oidc
      krew
      kubernetes-helm
      argocd
      k9s
    ];

    home.sessionPath = [
      "${config.home.homeDirectory}/.krew/bin"
    ];

    home.sessionVariables.KUBECONFIG = "${config.sops.secrets."k8s/homelab".path}:${
      inputs.lunar-tools.packages.${pkgs.system}.lunar-zsh-plugin
    }/.kube/config";
  };
}
