{writers, pandoc, entr, fetchFromGitHub, mkDerivation}:

rec {

  revealJs = fetchFromGitHub {
    owner = "hakimel";
    repo = "reveal.js";
    rev = "542bcab5691f152dd04fd7b3e402163b94275762";
    sha256 = "0hv3kl4x291ifsvjfk95pdnl51fyd164h96rd44mcflsslslqpnx";
  };

  # cleaned up version with all files in the right spot
  revealJsL = mkDerivation {
    src = revealJs;
    name = "reveal.js-dist";
    installPhase = ''
      mkdir -p $out;
      ln -s $src/css $out;
      ln -s $src/js $out;
      ln -s $src/plugin $out;
    '';
  };

  # build slides using pandoc.
  slides-build = writers.writeBashBin "slides-build" ''
    DOCUMENT=$1
    if [ ! -r "$DOCUMENT" ]; then
      echo "usage: $(basename $0) <slides.md> [additional pandoc arguments]"
      echo ""
      echo "compiles markdown as reveal js presentation '<slides.md>.html'"
      exit 1
    fi
    shift
    ln -sfT ${revealJsL} reveal.js
    ${pandoc}/bin/pandoc -t revealjs -s -o "$DOCUMENT".html "$DOCUMENT" $@
  '';

  slides-selfcontained= writers.writeBashBin "slides-selfcontained" ''
    DOCUMENT=$1; shift
    ${slides-build}/bin/slides-build $DOCUMENT --self-contained $@
    # --css ./css/print/paper.css
  '';

  slides-pdf = writers.writeBashBin "slides-pdf" ''
    DOCUMENT=$1; shift
    HTML=$DOCUMENT.html
    decktape $HTML $DOCUMENT.pdf
  '';


  slides-preview = writers.writeBashBin "slides-preview" ''
    DOCUMENT=$1
    HTML=$DOCUMENT.html

    echo "# watching for output changes and update slides"
    browser-sync start --server --index $HTML --files $HTML --logLevel silent --files **/*.css &
    BSPID=$!

    echo "# watching for input changes and recompile"
    ${entr}/bin/entr -a -n ${slides-build}/bin/slides-build $DOCUMENT <<< $DOCUMENT 2>&1 >/dev/null &
    ENTRPID=$!

    trap "kill $BSPID $ENTRPID" EXIT

    vim $DOCUMENT
    #${pandoc}/bin/pandoc -t revealjs -s -o ''${DOCUMENT}.html "''$DOCUMENT" -V revealjs-url=./tmp/reveal.js

    # create pdf after finishing editing
    # ${slides-pdf}/bin/slides-pdf $DOCUMENT > /dev/null 2&>/dev/null &
  '';
}
