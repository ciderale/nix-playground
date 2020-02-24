{ pkgs ? import ../nixpkgs.nix {} }:

with pkgs;

mkShell {
  buildInputs = [
    nodejs-12_x
    nodePackages_12_x.node2nix
  ];
}
