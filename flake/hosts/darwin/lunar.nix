{ lunar-tools, yazi, llm-agents }:
{
  system = "aarch64-darwin";
  user = "kisw";
  hostModule = ../../../hosts/darwin/work;
  homeModule = ../../../hosts/darwin/work/home.nix;
  nixDirectory = "/Users/kisw/nixfiles-v2";
  git = {
    fallback = "kirksw";
    profiles = {
      lunarway = {
        dirs = [
          "~/git/github.com/lunarway/**"
        ];
      };
      kirksw = {
        dirs = [
          "~/git/github.com/kirksw/**"
          "~/git/github.com/cntd-io/**"
          "~/nixfiles-v2/**"
        ];
      };
    };
  };
  ssh = {
    keys = [
      "kirksw"
      "lunarway"
      "default"
      "k8s"
      "ry4a"
      "ry6b"
    ];
  };
  overlays = [
    lunar-tools.overlays.default
    yazi.overlays.default
    llm-agents.overlays.default
  ];
  enableHomebrew = true;
  enableLunar = true;
}
