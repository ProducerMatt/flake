{
  services.thermald.enable = true;
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      # see available governors by running: cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
      governor = "powersave";
      # EPP: see available preferences by running: cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences
      energy_performance_preference = "power";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      energy_performance_preference = "performance";
      turbo = "auto";
    };
  };
}
