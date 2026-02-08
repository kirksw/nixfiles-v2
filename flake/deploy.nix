{ self, deploy-rs }:
{
  nodes.nixos-ry6a = {
    hostname = "nixos-ry6a";
    sshUser = "root";

    remoteBuild = true;
    factConnection = true;

    profiles.system = {
      user = "root";
      path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nixos-ry6a;
    };
  };
}
