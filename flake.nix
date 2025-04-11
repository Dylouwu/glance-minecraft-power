{
  description = "Minecraft Server Control API";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, sops-nix, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      # Development shell
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [ python313 python313Packages.flask sops ];
      };

      nixosModules.default = { ... }: {
        imports = [ sops-nix.nixosModules.sops ];

        systemd.services.minecraft-control-api = {
          description = "Minecraft Server Control API";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];

          environment = {
            MINECRAFT_API_KEY = "${"secret:minecraft-api-key"}";
          };

          serviceConfig = {
            ExecStart = "${pkgs.python3Packages.flask}/bin/python ${./app.py}";
            User = "minecraft";
            Group = "minecraft";
            Restart = "on-failure";
          };
        };
      };
    };
}

