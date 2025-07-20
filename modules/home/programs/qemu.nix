{
  pkgs,
  lib,
  config,
  ...
}:

{
  options = {
    qemu.enable = lib.mkEnableOption "enables qemu";
  };

  config = lib.mkIf config.qemu.enable {
    home.packages = with pkgs; [
      qemu
      #binfmt
    ];
  };
}
