{
  lib,
  inputs,
  config,
  ...
}: let
  cfg = config.matt.impermanence;
in {
  imports = [
    inputs.impermanence.nixosModules.impermanence
    ./disko-config.nix
  ];

  options.matt.impermanence = let
    inherit (lib.types) uniq str;
    inherit (lib.options) mkOption mkEnableOption;
    sizeType = lib.types.strMatching "[0-9]+[KMGTP]?";
  in {
    enable = mkEnableOption "enable impermanence";
    btrfsRootName = mkOption {
      type = uniq str;
      description = "Name used by disko and thus blkid";
      default = config.networking.hostName;
      defaultText = "config.networking.hostName";
    };
    swapsize = mkOption {
      type = sizeType;
      description = "Size of the swapfile to create";
      example = "16G";
    };
  };

  config =
    lib.mkIf cfg.enable
    {
      #  Reset root subvolume on boot
      boot.initrd.postResumeCommands = lib.mkAfter ''
        mkdir /btrfs_tmp
        mount /dev/disk/by-partlabel/disk-${cfg.btrfsRootName}-root /btrfs_tmp
        if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
          mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
        fi

        delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          btrfs subvolume delete "$1"
        }

        for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
        done

        btrfs subvolume create /btrfs_tmp/root
        umount /btrfs_tmp
      '';

      # Use /persist as the persistence root, matching Disko's mountpoint
      environment.persistence."/persist" = {
        hideMounts = true;
        directories = [
          "/etc" # System configuration (Keep this here for persistence via bind-mount)
          "/var/spool" # Mail queues, cron jobs
          "/srv" # Web server data, etc.
          "/root"
        ];
        files = [
        ];
      };

      # # Swapfile configuration (definition for Systemd)
      # swapDevices = [
      #   {
      #     device = "/persist/swapfile"; # Points to the persistent location of the swapfile
      #     size = ram_size_gb * 1024; # GB to MiB
      #   }
      # ];

      # # --- SWAPFILE INITIALIZATION & FORMATTING (CRITICAL for activation) ---
      # # 1. Ensure the swapfile exists at the specified size with correct permissions early via tmpfiles.
      # #    The ${toString (ram_size_gb  * 1024 * 1024 * 1024)} converts GB to bytes.
      # systemd.tmpfiles.rules = [
      #   "f /persist/swapfile 0600 - - ${toString (ram_size_gb * 1024 * 1024 * 1024)} -"
      # ];

      # # 2. Format the swapfile *only if it's not already formatted* during boot.
      # boot.initrd.postDeviceCommands = lib.mkAfter ''
      #   if ! blkid -p /persist/swapfile | grep -q 'TYPE="swap"'; then
      #     echo "NixOS: Formatting /persist/swapfile..."
      #     mkswap /persist/swapfile
      #   fi
      # '';
      # # --- END SWAPFILE INITIALIZATION & FORMATTING ---
    };
}
