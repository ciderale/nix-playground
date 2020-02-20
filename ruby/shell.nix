let
  # define an overlay to customize packages
  overlay = self: super: {
    # select your ruby version of choice
    # that affects all ruby related things in nixpkgs
    ruby = self.ruby_2_5;
  };

  # use a "frozen" version of nixpkgs (rather than <nixpkgs>)
  pkgs = import ./nixpkgs.nix {
    # apply the overlay to nixpkgs
    overlays = [overlay];
  };
in

# "with" move all packages (of 'pkgs') in scope, to avoid boilerplate
# this allows to write 'ruby' instead of 'pkgs.ruby'
with pkgs;

let
  # generate a ruby environment with all gems defined in Gemfile
  rubyEnvironment = bundlerEnv {
    name = "tmp-bundler-env";
    inherit ruby;
    gemfile  = ./Gemfile;       # manually defined
    lockfile = ./Gemfile.lock;  # generated with ``bundle``
    gemset   = ./gemset.nix;    # generated with ``bundix``
  };

  # combine the two commands for simpler regeneration
  # writeScriptBin creates an executable script named "rubix"
  rubix = pkgs.writeScriptBin "rubix" ''
    ${bundler}/bin/bundle && ${bundix}/bin/bundix
  '';

  # a "demo" script to know that ruby finds the gem
  demonstrateSuccess = pkgs.writeScriptBin "demo" ''
    echo "the following should print some like"
    echo "    require rbtree => true, and not an error"
    echo "Demo starting now..."
    echo ""
    echo "require 'rbtree'" | irb
  '';

in

# a brand new derivation (akin package) with the ruby shell
stdenv.mkDerivation {
  name = "ruby-sample";

  # all derivations in buildInputs are made available to nix-shell
  # this places any /bin folder of those packages onto the path
  # hence ruby and the previously defined script are readily available
  buildInputs = [

    # dev dependencies to install the gems
    bundler bundix rubix

    # the ruby interpreter to be used
    ruby

    # custom ruby environemnt as defined by the Gemfile
    # lock and nix file generated with rubix, aka bundle && bundix
    rubyEnvironment

    # provide a simple script to check that it is all working
    # simply run ``demo`` in a nix-shell or direnv environment
    demonstrateSuccess
  ];

  shellHook = ''
    # an extra goodie, this will be run when entering the nix-shell
    ${demonstrateSuccess}/bin/demo
    demo # non-absolute paths works, because of buildInputs!

    # sometimes convenient to reference the project top-level folder
    export PROJECT_DIR=$(pwd)
  '';
}
