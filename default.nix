
{ pkgs ? import <nixpkgs> {} }:
let
    dynamic-linker = pkgs.stdenv.cc.bintools.dynamicLinker;
in
pkgs.stdenv.mkDerivation rec {
  pname = "roamresearch";
  version = "0.0.13";
  src = builtins.fetchurl {
    url = "https://roam-electron-deploy.s3.us-east-2.amazonaws.com/roam-research_${version}_amd64.deb";
    sha256 = "1bg6jvi05m6qc9qrspp53jzjcpqbyi20lv5pi6x4rh7v6sb9vah9";
  };
  nativeBuildInputs = [
    pkgs.autoPatchelfHook
    pkgs.dpkg
  ];
  dontConfigure = true;
  dontBuild = true;
  buildInputs = with pkgs; [ 
    libcxx
    cairo.dev
    pango.dev
    glib.dev
    mesa
    xorg.libxcb.dev
    xorg.libXrandr.dev
    xorg.libXrender.dev
    xorg.libX11
    xorg.xmodmap
    xorg.libxshmfence
    xorg.libXext
    pkgs.nss.dev
    cups.dev
    gdk-pixbuf.dev
    xorg.libXdamage
    libxkbcommon
    libdrm
    gdk-pixbuf-xlib
    pkgs.gtk3.dev
    xorg.libXcomposite
    atk.dev
    xorg.libxcb
    alsaLib
    ffmpeg.dev
  ];
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath buildInputs;

  rpath = with pkgs; lib.concatStringsSep ":" [
    atomEnv.libPath
    "$out/bin/roam-research"
  ];
  unpackPhase = ''
    mkdir pkg
    dpkg -x $src pkg
    cp -r pkg/usr/share .
    cp -r pkg/opt .
    mkdir -p $out/bin
    cp -r ./{share,opt} $out
    ln -s "$out/opt/Roam Research/roam-research" $out/bin
  '';
   installPhase = ''
    patchelf \
      --set-interpreter "${dynamic-linker}" \
      --set-rpath "${rpath}" \
      "$out/opt/Roam Research/roam-research"

    runHook postInstall
  '';
}
