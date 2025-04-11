{
  description = "Glance Minecraft Power API";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [ python313 python313Packages.flask sops ];
      };

      nixosModules.glance-minecraft-power = { config, lib, pkgs, ... }: {
        options.services.glance-minecraft-power = {
          enable = lib.mkEnableOption "Enable the Glance Minecraft Power API service";
          port = lib.mkOption {
            type = lib.types.int;
            default = 5000;
            description = "Port for the Glance Minecraft Power API";
          };
          apiKeyPath = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "API key path for the Glance Minecraft Power API";
          };
        };
        config = lib.mkIf config.services.glance-minecraft-power.enable {
          systemd.services.glance-minecraft-power = {
            description = "Glance Minecraft Power API";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig = {
              ExecStart = "${pkgs.python313}/bin/python ${./app.py}";
              User = "minecraft";
              Group = "minecraft";
              Restart = "on-failure";
              environment = [
                "FLASK_APP=${pkgs.python313}/bin/flask"
                "FLASK_ENV=production"
                "FLASK_RUN_PORT=${toString config.services.glance-minecraft-power.port}"
                "API_KEY_PATH=${config.services.glance-minecraft-power.apiKeyPath}"
              ];
            };
          };
        };
      };
    };
}
