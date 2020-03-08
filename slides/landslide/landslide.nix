{ lib, buildPythonPackage, fetchPypi, markdown }:

buildPythonPackage rec {
  pname = "landslide";
  version = "1.1.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "16m0n0d334m95ab837qb327j9y6ss14hdvrlxsb9h4y6d23i1swk";
  };

  doCheck = false;

  propagatedBuildInputs = [markdown];

  meta = with lib; {
    homepage = http://github.com/adamzap/landslide;
    description = "Landslide takes your Markdown, ReST, or Textile file(s) and generates fancy HTML5 slideshow";
    license = licenses.asl20;
  };
}
