# nix-pinning nixpkgs-unstable
# committed on "2020-02-11T22:08:30Z" - retrieved on 2020-02-20
import  (builtins.fetchTarball {
  name   = "nixos_nixpkgs-channels-nixpkgs-unstable-2020-02-11";
  url    = "https://github.com/nixos/nixpkgs-channels/archive/f77e057cda60a3f96a4010a698ff3be311bf18c6.tar.gz";
  sha256 = "0j4m572dz6ak49mf3c0q4aq1z0qzm7qn08amygym27j55gh197zf";
})
