let
  nixpkgs = builtins.getFlake "nixpkgs";
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
in

with pkgs; stdenv.mkDerivation {
  name = "openwrt-build";
  buildInputs = with pkgs; [
    which

    coreutils
    curl
    file
    gawk
    getopt
    gettext
    gitAndTools.git
    hexdump
    libxslt
    ncurses
    openssl
    perl
    python2
    subversion
    unzip
    zlib.dev
    zlib.static
    wget

    cacert
  ];
}
