# overlay to select the nodejs version
nodeVersion1: self: super: let
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

  # create a setup-hook to add NODE_PATH and PATH for npm dependencies
  makeNodeEnv = pkg: super.writeTextDir "/nix-support/setup-hook" ''
    addToSearchPath NODE_PATH ${pkg.nodeDependencies}/lib/node_modules
    addToSearchPath PATH ${pkg.nodeDependencies}/bin
    addToSearchPath PATH ${self.nodix}/bin
  '';

  # import and customize generated node2nix definition
  # use only package(-lock).json and add a buildInput ready environment
  callNode2nix = path: { buildInputs ? [] }:
    let
      node2nixRaw = import path { pkgs = self; };
      customize = _: p: p.override {
        # use the provide additional buildInputs
        inherit buildInputs;
        # ignore everything, but the package dependency definition
        # we only fetch dependencies, don't package the project for nix
        src = builtins.filterSource self.onlyPackageJsonOrLock path;
      };
      node2nixCustomized = builtins.mapAttrs customize node2nixRaw;
      # create an environment with all npm depenedencies available
      node2nixEnv = self.makeNodeEnv node2nixCustomized.shell;
    in node2nixCustomized // { env = node2nixEnv; };
}
