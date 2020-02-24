let
  # overlay to select the nodejs version
  selectNodejs = nodeVersion1: self: super: let
    nodeVersion = toString nodeVersion1;
  in {
    nodejs = super."nodejs-${nodeVersion}_x";
    nodePackages = super."nodePackages_${nodeVersion}_x".node2nix;

    # the command to generate nix expressions from package-lock.json
    # run 'npm install --save[-dev] your depenency' to generate the lock file
    # run 'nodeix' to generate the necessary nix files replicating the lock
    nodix = super.writers.writeBashBin "nodix" ''
      rm -rf ./node_modules # node2nix complains as node_modules interfer
      ${self.nodePackages}/bin/node2nix -d --nodejs-${nodeVersion} -l package-lock.json
    '';

    # filter to retain only package.json and its lock file
    # this is minimal, when only npm depenency shall be managed
    onlyPackageJsonOrLock = path: _:
      let baseName = baseNameOf (toString path);
       in baseName == "package.json" || baseName == "package-lock.json";
  };

  # load your favourite nixpkgs set and select the nodejs version
  # NOTE: select the nodejs version you like to use
  pkgs = import ../nixpkgs.nix { overlays = [(selectNodejs 12)]; };

  # load the node2nix generated default.nix file
  n2n = import ./. { inherit pkgs; };
  # and override to slightly customize the generated node project dependencies
  myNodePackage = n2n.shell.override {
    # NOTE: this may require adjustments to your selected npm packages
    # the current example depends on fsevents which requires CoreService os Mac
    buildInputs = pkgs.lib.optionals pkgs.stdenv.isDarwin (
      with pkgs.darwin.apple_sdk.frameworks; [CoreServices]
    );

    # ignore everything, but the package dependency definition
    # we only fetch dependencies, don't package the project for nix
    src = builtins.filterSource pkgs.onlyPackageJsonOrLock ./.;
  };
in

with pkgs;

mkShell {
  # inherit the shellHook (and its nodeDependency)
  inherit (myNodePackage) shellHook nodeDependencies;

  # include the update script and the correct version of nodejs itself
  buildInputs = [ nodejs nodix ];
}
