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
  demonstrateSuccess = pkgs.writeScriptBin "demo" ''
    echo "the following should print some like"
    echo "    require rbtree => true, and not an error"
    echo "Demo starting now..."
    echo ""
    echo "require 'rbtree'" | irb
  '';
in stdenv.mkDerivation {
  name = "ruby-sample";
  buildInputs = [
    bundler bundix rubix
    ruby
    # custom environemnt.. generated with rubix, aka bundle && bundix
    rubyEnvironment

    # sample ruby session to demonstrate the gem is available
    # simply run ``demo`` in a nix-shell or direnv environment
    demonstrateSuccess
  ];

  shellHook = ''
    # an extra goodie, this will be run when entering the nix-shell
    ${demonstrateSuccess}/bin/demo >&2  # direnv is picky on stdout!
  '';
}
