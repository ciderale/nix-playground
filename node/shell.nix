let
  pkgs = import ../nixpkgs.nix {};
  n2n = import ./. {pkgs=pkgs;};

  # the commoand to generate nix expressions from package-lock.json
  updateNix = pkgs.writers.writeBashBin "updateNix" ''
    node2nix --nodejs-12 -l package-lock.json
  '';
in
with pkgs;

mkShell {
  inherit (n2n.shell) shellHook nodeDependencies;
  buildInputs = [nodejs-12_x nodePackages_12_x.node2nix updateNix];
}
