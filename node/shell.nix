let
  pkgs = import ../nixpkgs.nix {};
  n2n = import ./. {pkgs=pkgs;};

  np = n2n // {
    webpack = n2n.webpack.override {
      buildInputs = with pkgs.darwin.apple_sdk.frameworks; [CoreServices];
    };
  };

  # the commoand to generate nix expressions from package-lock.json
  nodix = pkgs.writers.writeBashBin "nodix" ''
    rm -rf ./node_modules
    node2nix -d --nodejs-12 -l package-lock.json
  '';

  # this exposes variant exposes all the defined packages
  # and thus suitable for overrides
  nodix2 = pkgs.writers.writeBashBin "nodix2" ''
    rm -rf ./node_modules
    node2nix --nodejs-12 -i <(cat package.json| jq '.devDependencies | to_entries | map({(.key): .value})')
  '';
in
with pkgs;

mkShell {
  #inherit (np.shell) shellHook nodeDependencies;
  buildInputs = [nodejs-12_x nodePackages_12_x.node2nix 
   nodix nodix2
 #   np.webpack
  ];
}
