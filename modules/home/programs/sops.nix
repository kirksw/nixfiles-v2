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
  keyOf = profile: (git.profiles.${profile}.sshKey or "default");

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
        "sshKey"
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
            #path = "%r/git/${profileName}/${property}";
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
          #path = "%r/git/${profileName}/gitconfig";
          content = ''
            [user]
                name = ${config.sops.placeholder."git/${profileName}/name"}
                email = ${config.sops.placeholder."git/${profileName}/email"}

            [gpg]
                format = ssh
            [commit]
                gpgsign = true
            [user]
                signingKey = ${config.sops.secrets."ssh/${keyOf profileName}/public".path}

            [url "github-${config.sops.placeholder."git/${profileName}/org"}"]
                insteadOf = https://github.com/${config.sops.placeholder."git/${profileName}/org"}/
          '';
        };
      }) profileNames
    );

  # generateGitSshTemplates =
  #   profileNames:
  #   builtins.listToAttrs (
  #     builtins.map (profileName: {
  #       name = "ssh-host-${profileName}";
  #       value = {
  #         mode = "0400";
  #         content = ''
  #           host github.com-${config.sops.placeholder."git/${profileName}/org"}
  #             hostname github.com
  #             user git
  #             identityFile ${config.sops.secrets."ssh/${keyOf profileName}/private".path}
  #             identitiesOnly yes
  #             AddKeysToAgent yes
  #             UseKeychain yes
  #         '';
  #       };
  #     }) profileNames
  #   );
in
{
  options = {
    sops.enable = lib.mkEnableOption "enables sops";
  };

  config = lib.mkIf config.sops.enable {
    sops = {
      #defaultsopsfile = "${self}/secrets/secrets.yaml";
      defaultSopsFormat = "yaml";
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      # define the required secrets for git profiles
      secrets =
        generateGitSecrets {
          inherit profileNames;
        }
        // generateSshSecrets {
          keys = ssh.keys;
        };

      templates = generateGitTemplates profileNames; # // generateGitSshTemplates profileNames;
    };
  };
}
