let
  sources = import ./nix/sources.nix;
  selectNodejs = import ./node/selectNodeJs.nix 12;
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

  pd = import ./slides/pandoc {
    inherit (pkgs) writers pandoc entr fetchFromGitHub;
  };

in
with pkgs;
mkShell {
  buildInputs = [
    marp
    slide-js-tools
  ];
}

