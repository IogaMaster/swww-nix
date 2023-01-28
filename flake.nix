{
  description = "A flake for swww";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    swww-src = {
      url = "github:Horus645/swww/a5abb25243161928b05e621691b2874e90086cd1";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, swww-src }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      swww = pkgs.rustPlatform.buildRustPackage
        {
          name = "swww";
          version = "0.6.0";
          src = swww-src;
          cargoSha256 = "4ToAD33Aj5PtqrPvgkokaKeJqDcBr44UZP4UygafTg4=";
          doCheck = false;
          buildInputs = with pkgs; [ lz4 libxkbcommon ];
          nativeBuildInputs = with pkgs; [ pkg-config ];
        };
      overlays = {
        swww = _: prev: {
          swww = self.swww;
        };
        default = self.overlays.swww;
      };

      homeManagerModules.default = { config, lib, pkgs, ... }:
        let cfg = config.programs.swww;
        in
        {
          options.programs.swww = {
            enable = lib.mkEnableOption
              "swww, a solution to your wayland wallpaper woes";
            package = lib.mkOption {
              type = lib.type.package;
              default = self.packages.x86_64-linux.default;
            };
            systemd = {
              enable = lib.mkEnableOption "Enable systemd integration";
              target = lib.mkOption {
                type = lib.types.str;
                default = "graphical-session.target";
              };
            };
          };
          config = lib.mkIf cfg.enable (lib.mkMerge [
            { home.packages = lib.optional (cfg.package != null) cfg.package; }

            (lib.mkIf cfg.systemd.enable {
              systemd.user.services.swww = {
                Unit = {
                  Description =
                    "swww, a solution to your wayland wallpaper woes";
                  Documentation = "https://github.com/Hourus645/swww";
                  PartOf = [ "graphical-session.target" ];
                  After = [ "graphical-session.target" ];
                };

                Service = {
                  ExecStart = "${cfg.package}/bin/swww-daemon";
                  ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
                  Restart = "on-failure";
                  KillMode = "mixed";
                };
                Install = { WantedBy = [ cfg.systemd.target ]; };
              };
            })
          ]);
        };
    };
}
