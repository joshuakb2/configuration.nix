{ lib, stdenv, fetchFromGitHub, cmake, meson, pkg-config, vulkan-loader, ninja, writeText, vulkan-headers, vulkan-utility-libraries,  jq, libX11, libXrandr, libxcb, wayland, wayland-scanner }:

stdenv.mkDerivation rec {
  pname = "vulkan-hdr-layer";
  version = "63d2eec";

  src = (fetchFromGitHub {
    owner = "Zamundaaa";
    repo = "VK_hdr_layer";
    rev = "63d2eeccb962824c90e158a06900ae1abec9c49e";
    fetchSubmodules = true;
    hash = "sha256-IwHrMTiOzITMsGMZN/AuUN3PF/oMhENw9d7kX2VnDGM=";
  }).overrideAttrs (_: {
    GIT_CONFIG_COUNT = 1;
    GIT_CONFIG_KEY_0 = "url.https://github.com/.insteadOf";
    GIT_CONFIG_VALUE_0 = "git@github.com:";
  });

  nativeBuildInputs = [ vulkan-headers meson ninja pkg-config jq ];

  buildInputs = [ cmake vulkan-headers vulkan-loader vulkan-utility-libraries libX11 libXrandr libxcb wayland wayland-scanner ];

  # Help vulkan-loader find the validation layers
  setupHook = writeText "setup-hook" ''
    addToSearchPath XDG_DATA_DIRS @out@/share
  '';

  meta = with lib; {
    description = "Layers providing Vulkan HDR";
    homepage = "https://github.com/Zamundaaa/VK_hdr_layer";
    platforms = platforms.linux;
    license = licenses.mit;
  };
}
