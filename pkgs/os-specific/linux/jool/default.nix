{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
  nixosTests,
}:

let
  sourceAttrs = (import ./source.nix) { inherit fetchFromGitHub; };
in

stdenv.mkDerivation {
  name = "jool-${sourceAttrs.version}-${kernel.version}";

  src = sourceAttrs.src;

  nativeBuildInputs = kernel.moduleBuildDependencies;
  hardeningDisable = [ "pic" ];

  prePatch = ''
    sed -e 's@/lib/modules/\$(.*)@${kernel.dev}/lib/modules/${kernel.modDirVersion}@' -i src/mod/*/Makefile
  '';

  makeFlags = kernelModuleMakeFlags ++ [
    "-C src/mod"
    "INSTALL_MOD_PATH=${placeholder "out"}"
  ];

  installTargets = "modules_install";

  passthru.tests = {
    inherit (nixosTests) jool;
  };

  meta = {
    homepage = "https://www.jool.mx/";
    description = "Fairly compliant SIIT and Stateful NAT64 for Linux - kernel modules";
    platforms = lib.platforms.linux;
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fpletz ];
  };
}
