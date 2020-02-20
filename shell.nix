let
  overlay = self: super: {
    # select your ruby version of choice
    # that affect all ruby related things in nixpkgs
    ruby = self.ruby_2_5;
  };
  pkgs = import <nixpkgs> {overlays=[overlay];};
in

with pkgs;

let
  rubyEnvironment = bundlerEnv {
    name = "tmp-bundler-env";
    inherit ruby;
    gemfile  = ./Gemfile;       # manually defined
    lockfile = ./Gemfile.lock;  # generated with ``bundle``
    gemset   = ./gemset.nix;    # generated with ``bundix``
  };
  rubix = pkgs.writeScriptBin "rubix" ''
    ${bundler}/bin/bundle && ${bundix}/bin/bundix
  '';
in stdenv.mkDerivation {
  name = "ruby-sample";
  buildInputs = [
    bundler bundix rubix
    ruby
    # custom environemnt.. require ``rubix`` to be run before uncomenting
    #rubyEnvironment
  ];
}
