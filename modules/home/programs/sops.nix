{
  self,
  lib,
  config,
  git,
  ssh,
  ...
}:

let
  profileNames = builtins.attrNames git.profiles;

  generateSshSecrets =
    {
      keys,
      secretsDir ? "${self}/secrets",
    }:
    lib.attrsets.mergeAttrsList (
      map (key: {
        "ssh/${key}/private" = {
          sopsFile = "${secretsDir}/ssh/${key}.yaml";
          key = "private";
          mode = "0400";
        };

        "ssh/${key}/public" = {
          sopsFile = "${secretsDir}/ssh/${key}.yaml";
          key = "public";
          mode = "0600";
        };
      }) keys
    );

  generateGitSecrets =
    {
      profileNames,
      secretsDir ? "${self}/secrets",
      properties ? [
        "name"
        "email"
        "org"
      ],
    }:
    builtins.listToAttrs (
      builtins.concatMap (
        profileName:
        builtins.map (property: {
          name = "git/${profileName}/${property}";
          value = {
            sopsFile = "${secretsDir}/git/${profileName}.yaml";
            key = "${property}";
            mode = "0400";
          };
        }) properties
      ) profileNames
    );

  generateGitTemplates =
    profileNames:
    builtins.listToAttrs (
      builtins.map (profileName: {
        name = "gitprofile-${profileName}";
        value = {
          mode = "0400";
          content = ''
            [user]
                name = ${config.sops.placeholder."git/${profileName}/name"}
                email = ${config.sops.placeholder."git/${profileName}/email"}
            [gpg]
                format = ssh
            [commit]
                gpgsign = true
            [user]
                signingKey = ${config.sops.secrets."ssh/${profileName}/public".path}
            [url "github.com-${profileName}"]
                insteadOf = https://github.com/${config.sops.placeholder."git/${profileName}/org"}/
          '';

        };
      }) profileNames
    );
in
{
  options = {
    sops.enable = lib.mkEnableOption "enables sops";
  };

  config = lib.mkIf config.sops.enable {
    sops = {
      defaultSopsFormat = "yaml";
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      # define the required secrets for git profiles
      secrets =
        generateGitSecrets {
          inherit profileNames;
        }
        // generateSshSecrets {
          keys = ssh.keys;
        }
        // {
          "k8s/homelab" = {
            sopsFile = "${self}/secrets/k8s/homelab.yaml";
            key = "config";
            mode = "0400";
          };
        };

      templates = generateGitTemplates profileNames;
    };
  };
}
