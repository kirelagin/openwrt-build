with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "openwrt-build";
  buildInputs = with pkgs; [
    gawk
    gettext
    gitAndTools.git
    libxslt
    ncurses
    openssl
    subversion
    zlib
    wget
  ];
}
