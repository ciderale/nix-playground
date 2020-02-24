let
  pkgs = import ../nixpkgs.nix {};
  n2n = import ./. {pkgs=pkgs;};
in
with pkgs;

mkShell {
  inherit (n2n.shell) shellHook nodeDependencies;
  buildInputs = [nodejs-12_x];
}
