let
  # load your favourite nixpackage set
  pkgs = import ../nixpkgs.nix {};

  # load the node2nix generated default.nix file
  n2n = import ./. {pkgs=pkgs;};

  # filter to retain only package.json and its lock file
  onlyPackageJsons = path: _:
    let baseName = baseNameOf (toString path);
     in baseName == "package.json" || baseName == "package-lock.json";

  # override to slightly customize the generated node project dependencies
  np = n2n // {
    shell = n2n.shell.override {
      # buildInput needed to build webpack
      buildInputs = with pkgs.darwin.apple_sdk.frameworks; [CoreServices];

      # ignore everything, but the package dependency definition
      # we only fetch dependencies, don't package the project for nix
      src = builtins.filterSource onlyPackageJsons ./.;
    };
  };

  # the commoand to generate nix expressions from package-lock.json
  nodix = pkgs.writers.writeBashBin "nodix" ''
    rm -rf ./node_modules # node2nix complains as node_modules interfer
    node2nix -d --nodejs-12 -l package-lock.json
  '';
in

with pkgs;

mkShell {
  # inherit the shellHook (and its nodeDependency)
  inherit (np.shell) shellHook nodeDependencies;

  buildInputs = [
    # the node version to be used
    nodejs-12_x nodePackages_12_x.node2nix
    # our little helper script
    nodix
  ];
}
