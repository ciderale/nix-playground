let
  selectNodejs = import ./node/selectNodeJs.nix 12;
  pkgs = import ./nixpkgs.nix {overlays=[selectNodejs];};

  buildInputs = [pkgs.darwin.apple_sdk.frameworks.CoreServices];
in
with pkgs;
mkShell {
  buildInputs = [
    nodix
  ];
}

