{ config, pkgs, lib, ... }:
systemd.services.minecraft-control-api = {
  description = "Minecraft Server Control API";
  after = [ "network.target" ];
  wantedBy = [ "multi-user.target" ];
  
  environment = {
    MINECRAFT_API_KEY = "${secret:minecraft-api-key}";
  };
  
  serviceConfig = {
    ExecStart = "${pkgs.python3}/bin/python3 ${/path/to/app.py}";
    User = "minecraft";
    # Additional service configuration...
  };
};
