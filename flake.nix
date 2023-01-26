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
        swww = _: prev: { swww = self.packages.x86_64-linux.swww; };
        default = self.overlays.swww;
      };
    };
}
