{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:

let
  kube1 = config.sops.secrets."k8s/homelab".path;
  kube2 = "${inputs.lunar-tools.packages.${pkgs.system}.lunar-zsh-plugin}/.kube/config";
in
{
  options = {
    devops.enable = lib.mkEnableOption "enables devops tooling";
  };

  config = lib.mkIf config.devops.enable {
    home.packages = with pkgs; [
      # IaC
      tenv

      # container/kubernetes
      awscli2
      fluxcd
      docker
      kustomize
      kubeconform
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

    home.sessionVariables = {
      KUBECONFIG = builtins.concatStringsSep ":" [
        kube1
        kube2
      ];
      DOG = "xyz";
    };

    home.file.".myfile".text = ''
      ${kube1}
      ${kube2}
    '';
  };
}
