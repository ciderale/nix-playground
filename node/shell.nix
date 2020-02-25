let
  # load your favourite nixpkgs set and select the nodejs version
  # NOTE: select the nodejs version you like to use
  selectNodeJs = import ./selectNodeJs.nix 12;
  pkgs = import ../nixpkgs.nix { overlays = [selectNodeJs]; };

in with pkgs; let

  # load the node2nix generated default.nix file
  # and override to slightly customize the generated node project dependencies
  # NOTE: this may require adjustments to your selected npm packages
  # the current example depends on fsevents which requires CoreService os Mac
  myNodePackage = callNode2nixEnv ./. {
    buildInputs = lib.optionals stdenv.isDarwin (
      with darwin.apple_sdk.frameworks; [CoreServices]
    );
  };
in

mkShell {

  # include nodejs dependencies in the correct version
  buildInputs = [ nodejs myNodePackage ];
}
