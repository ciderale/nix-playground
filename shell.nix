let
  selectNodejs = import ./node/selectNodeJs.nix 12;
  pkgs = import ./nixpkgs.nix {overlays=[selectNodejs];};

  buildInputs = [pkgs.darwin.apple_sdk.frameworks.CoreServices];

  marp = pkgs.callNode2nix ./slides/marp { inherit buildInputs; };
  slide-js-tools = pkgs.callNode2nix ./slides/slide-js-tools { inherit buildInputs; };

  pd = import ./slides/pandoc {
    inherit (pkgs) writers pandoc entr fetchFromGitHub;
  };

in
with pkgs;
mkShell {
  buildInputs = [
    nodix nodejs
    marp.env
    slide-js-tools.env
  ];
}

