{
  self,
  pkgs,
  ...
}: let
  start_emacs = "emacsclient -c -a 'emacs'";

  myAliases = {
    l = "eza";
    ll = "eza -la";
    la = "eza -a";
    e = start_emacs;
    er = "systemctl --user restart emacs.service";
    v = "nvim";

    # quick cd
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";

    # internet ip
    # TODO: explain this hard-coded IP address
    myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";

    # nix
    n = "nix";
    #np = "n profile";
    #ni = "np install";
    #nr = "np remove";
    #ns = "n search --no-update-lock-file";
    #nf = "n flake";
    #nepl = "n repl '<nixpkgs>'";
    #srch = "ns nixos";
    #orch = "ns override";
    mn = ''
      manix "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | sk --preview="manix '{}'" | xargs manix
    '';

    ## sudo
    #s = "sudo -E ";
    #si = "sudo -i";
    #se = "sudoedit";

    # nix
    nrb = "sudo nixos-rebuild";

    # fix nixos-option for flake compat
    nixos-option = "nixos-option -I nixpkgs=${self}/lib/compat";

    ## systemd
    #ctl = "systemctl";
    #stl = "s systemctl";
    #utl = "systemctl --user";
    #ut = "systemctl --user start";
    #un = "systemctl --user stop";
    #up = "s systemctl start";
    #dn = "s systemctl stop";
    #jtl = "journalctl";

    # git
    gs = "git status";
    gcm = "git commit -m";
    gca = "git commit --amend";
    gcan = "git diff-index --quiet HEAD -- && git commit --amend --no-edit || begin; echo \"Error: Repository has uncommitted changes\"; false; end;";
  };
in {
  home.sessionVariables = {
    TERM = "xterm-direct";
    COLORTERM = "truecolor";

    EDITOR = "hx";
    VISUAL = "hx";
  };
  programs.fish = {
    enable = true;
    shellAliases = myAliases;
    shellInit = ''
      set fish_24bitcolor 1
      fish_config theme choose "ayu Dark"
      fish_config prompt choose "acidhub"
    '';
  };
  programs.bash = {
    enable = true;
    initExtra = builtins.readFile ./bash_prompt.sh;
    shellAliases = myAliases;
  };

  services.emacs = {
    enable = true;
    package = pkgs.emacs-unstable;
  };

  programs.pay-respects = {
    enable = true;
  };

  home.shell.enableShellIntegration = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
