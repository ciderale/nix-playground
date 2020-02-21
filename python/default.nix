{ pkgs ? import ../nixpkgs.nix {} }:

with pkgs;

let

myPython = python37.withPackages (ps: with ps; [
  numpy pandas matplotlib ipython
  jupyter
]);

in

mkShell {
  buildInputs = [myPython];
}
