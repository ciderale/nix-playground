{writers, pandoc, entr}:

rec {
  slides-build = writers.writeBashBin "slides-build" ''
    DOCUMENT=$1
    ${pandoc}/bin/pandoc -t revealjs -s -o ''${DOCUMENT}.html "''$DOCUMENT" -V revealjs-url=./tmp/reveal.js
  '';

  slides-pdf = writers.writeBashBin "slides-pdf" ''
    DOCUMENT=$1
    HTML=$DOCUMENT.html
    decktape $HTML $DOCUMENT.pdf
  '';


  slides-preview = writers.writeBashBin "slides-preview" ''
    DOCUMENT=$1
    HTML=$DOCUMENT.html

    browser-sync start --server --index $HTML --files $HTML --logLevel silent --files **/*.css &
    BSPID=$!

    ${entr}/bin/entr -a -n ${slides-build}/bin/slides-build $DOCUMENT <<< $DOCUMENT 2>&1 >/dev/null &
    ENTRPID=$!

    trap "kill $BSPID $ENTRPID" EXIT

    vim $DOCUMENT
    ${pandoc}/bin/pandoc -t revealjs -s -o ''${DOCUMENT}.html "''$DOCUMENT" -V revealjs-url=./tmp/reveal.js

    # create pdf after finishing editing
    # ${slides-pdf}/bin/slides-pdf $DOCUMENT > /dev/null 2&>/dev/null &
  '';
}
