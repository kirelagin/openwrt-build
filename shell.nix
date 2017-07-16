with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "openwrt-build";
  buildInputs = with pkgs; [
    file
    gawk
    gettext
    gitAndTools.git
    libxslt
    ncurses
    openssl
    python2
    subversion
    unzip
    zlib.dev
    zlib.static
    wget
  ];
}
