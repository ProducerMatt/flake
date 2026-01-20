{ den, ... }:
{
  den.default.nixos.system.stateVersion = "25.05";
  den.default.homeManager.home.stateVersion = "25.05";
  den.default.darwin.system.stateVersion = 6;

  den.default.includes = [
    den._.home-manager
    den._.define-user
    den.aspects.no-boot
  ];

  den.aspects.no-boot.nixos = {
    boot.loader.grub.enable = false;
    fileSystems."/".device = "/dev/fake";
  };
}
