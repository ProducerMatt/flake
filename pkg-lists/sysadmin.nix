pkgs:
with pkgs; [
  ethtool
  smartmontools
  lsof # list files and sockets in use
  dua # disk space usage analyser
  #(nur.repos.ProducerMatt.cosmo.override {
  #    appList = ["pledge"];
  #    distRepo = false;
  #  })
]
