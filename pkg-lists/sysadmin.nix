pkgs:
with pkgs; [
  ethtool
  smartmontools
  #(nur.repos.ProducerMatt.cosmo.override {
  #    appList = ["pledge"];
  #    distRepo = false;
  #  })
]
