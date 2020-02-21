{ pkgs ? import ../nixpkgs.nix {} }:

with pkgs;

let

myPython = python37.withPackages (ps: with ps; [
  numpy pandas matplotlib ipython

  # maybe some jupyter notebooks
  jupyter

  # https://dash.plot.ly/getting-started (with interactive dashboards)
  dash
]);

in

mkShell {
  buildInputs = [myPython];
}
