{ stdenv, lib, cmake, openssl }:

stdenv.mkDerivation {
  name = "minisha256sum";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./src
      ./CMakeLists.txt
    ];
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ openssl ];
}
