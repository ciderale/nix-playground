let
  selectNodejs = import ./node/selectNodeJs.nix 12;
  pkgs = import ./nixpkgs.nix {overlays=[selectNodejs];};

  buildInputs = [pkgs.darwin.apple_sdk.frameworks.CoreServices];

  marp = pkgs.callNode2nix ./slides/marp { inherit buildInputs; };
in
with pkgs;
mkShell {
  buildInputs = [
    nodix nodejs
    marp.env
  ];
}

