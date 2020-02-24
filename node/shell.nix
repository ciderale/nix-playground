let
  pkgs = import ../nixpkgs.nix {};
  n2n = import ./. {pkgs=pkgs;};

  np = n2n // {
    shell = n2n.shell.override {
      buildInputs = with pkgs.darwin.apple_sdk.frameworks; [CoreServices];
    };
  };

  # the commoand to generate nix expressions from package-lock.json
  nodix = pkgs.writers.writeBashBin "nodix" ''
    rm -rf ./node_modules
    node2nix -d --nodejs-12 -l package-lock.json
    TD=./tmp
    mkdir -p $TD
    cp package{,-lock}.json $TD
    sed -i "s?src = ./.;?src = $TD;?" ./node-packages.nix
  '';
in
with pkgs;

mkShell {
  inherit (np.shell) shellHook nodeDependencies;
  buildInputs = [nodejs-12_x nodePackages_12_x.node2nix
   nodix np.shell
  ];
}
