{inputs, ...}: {
  imports = [
    inputs.disko.nixosModules.disko
  ];
  sops = {
    defaultSopsFile = ../../.sops.yaml; # Or the correct path to your .sops.yaml
    age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    age.keyFile = "/home/matt/.config/sops/age/keys.txt";

    secrets = {
      # NOTE: unsure how to actually use this
      # threads are kind of baffling and most just copy anyway
      # https://discourse.nixos.org/t/how-to-define-actual-ssh-host-keys-not-generate-new/31775
      "newPortable_host_key" = {
        sopsFile = ../../secrets/newPortable_host_key.yaml; # <-- Points to your password hash file
        owner = "root";
        group = "root";
        mode = "0440";
      };
    };
  };
}
