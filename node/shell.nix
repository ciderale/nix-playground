let
  pkgs = import ../nixpkgs.nix {};
  n2n = import ./. {pkgs=pkgs;};

  dummyFolder = "tmp";

  np = n2n // {
    shell = n2n.shell.override {
      buildInputs = with pkgs.darwin.apple_sdk.frameworks; [CoreServices];
      src = ./. + "/${dummyFolder}";
    };
  };

  # the commoand to generate nix expressions from package-lock.json
  nodix = pkgs.writers.writeBashBin "nodix" ''
    rm -rf ./node_modules
    node2nix -d --nodejs-12 -l package-lock.json
    mkdir -p ./${dummyFolder}
    cp package{,-lock}.json ./${dummyFolder}
  '';
in
with pkgs;

mkShell {
  inherit (np.shell) shellHook nodeDependencies;
  buildInputs = [nodejs-12_x nodePackages_12_x.node2nix
   nodix np.shell
  ];
}
