{pkgs, ...}: {
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userEmail = "58014742+ProducerMatt@users.noreply.github.com";
    userName = "Producer Matt";
    lfs.enable = true;
    extraConfig = {
      init = {defaultBranch = "main";};
      pull = {rebase = false;}; # setting to true was a mistake
    };
  };
}
