{
  description = "Glance Minecraft Power API";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [ python313 python313Packages.flask ];
      };

      packages.x86_64-linux.glance-minecraft-power =
        pkgs.python313Packages.buildPythonApplication {
          pname = "glance-minecraft-power";
          version = "1.0.0";

          src = ./.;

          nativeBuildInputs = [ pkgs.python313Packages.flake8 ];

          propagatedBuildInputs = with pkgs.python313Packages; [ flask ];

          meta = with pkgs.lib; {
            description = "Glance Minecraft Power API";
            license = licenses.mit;
            maintainers = with maintainers; [ "Dylouwu" ];
            platforms = [ "x86_64-linux" ];
          };
        };

      nixosModules.glance-minecraft-power = { config, lib, ... }: {
        options.services.glance-minecraft-power = {
          enable =
            lib.mkEnableOption "Enable the Glance Minecraft Power API service";
          minecraftServerName = lib.mkOption {
            type = lib.types.str;
            default = "default";
            description = "Name of the Minecraft server";
          };
          host = lib.mkOption {
            type = lib.types.str;
            default = "localhost";
            description = "Host for the Glance Minecraft Power API";
          };
          port = lib.mkOption {
            type = lib.types.int;
            default = 5000;
            description = "Port for the Glance Minecraft Power API";
          };
          apiKeyPath = lib.mkOption {
            type = lib.types.path;
            default = "/etc/minecraft/api-key.txt";
            description = "API key path for the Glance Minecraft Power API";
          };
        };
        config = lib.mkIf config.services.glance-minecraft-power.enable {
          systemd.services.glance-minecraft-power = {
            description = "Glance Minecraft Power API";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];

            serviceConfig = {

              ExecStart = "${
                  self.packages.${system}.glance-minecraft-power
                }/bin/glance-minecraft-power";

              User = "minecraft";
              Group = "minecraft";
              Restart = "on-failure";
              Environment = [
                "MINECRAFT_SERVER_NAME=${config.services.glance-minecraft-power.minecraftServerName}"
                "FLASK_HOST=${config.services.glance-minecraft-power.host}"
                "FLASK_PORT=${
                  toString config.services.glance-minecraft-power.port
                }"
                "API_KEY_PATH=${config.services.glance-minecraft-power.apiKeyPath}"
              ];
            };
          };
        };
      };
    };
}
