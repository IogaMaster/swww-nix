{
  description = "A flake for swww";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    swww-src = {
      url = "github:Horus645/swww";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, swww-src }:
    let
      inherit (nixpkgs) lib;
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      swww = pkgs.rustPlatform.buildRustPackage
        {
          name = "swww";
          version = "0.6.0";
          src = swww-src;
          cargoSha256 = "NV4QPM+rU3VwXIsk0ZajECjKp1ENqqZHJYqL1pT7ftA=";
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
    };
}
