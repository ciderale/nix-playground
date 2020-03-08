let
  pkgs = import ../../nixpkgs.nix {};
in with pkgs;
let
  # define landslide via requirments.txt
  reqs = import ./requirements.nix { inherit pkgs; };
  landslide = reqs.packages.landslide;

  #there are version issues with the available versions in nixpkgs
  #landslide = callPackage ./landslide.nix {
    #inherit (python37Packages) buildPythonPackage fetchPypi markdown;
  #};
  #py = python37.withPackages (ps: with ps; [pygments jinja2 ]);
in

mkShell {
  buildInputs = [pypi2nix landslide];
}


