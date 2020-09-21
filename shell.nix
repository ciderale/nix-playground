let
  sources = import ./nix/sources.nix;
  selectNodejs = import ./node/selectNodeJs.nix 10;
  napalmOverlay = self: super: {
    napalm = p: arg@{...}: let
      np = self.callPackage sources.napalm arg;
    in np.buildPackage p {};
  };
  pkgs = import sources.nixpkgs {
    overlays=[selectNodejs napalmOverlay];
  };

  buildInputs = [pkgs.darwin.apple_sdk.frameworks.CoreServices];

  marp = pkgs.napalm ./slides/marp { };
  slide-js-tools = pkgs.napalm ./slides/slide-js-tools { };

  nixgrep = pkgs.writers.writeBashBin "nixgrep" ''
    ${pkgs.ripgrep}/bin/rg $@ ${pkgs.path}
  '';

  pd = import ./slides/pandoc {
    inherit (pkgs) writers pandoc entr fetchFromGitHub;
    mkDerivation = pkgs.stdenv.mkDerivation;
  };

in
with pkgs;
mkShell {
  buildInputs = [
    nodejs
    #marp
    slide-js-tools
    (builtins.attrValues pd)
    ripgrep
    nixgrep
  ];
}

