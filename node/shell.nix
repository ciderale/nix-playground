let
pkgs = import ../nixpkgs.nix {};
n2n = import ./. {pkgs=pkgs;};
in
n2n.shell
