{ lib, fetchFromGitHub, rustPlatform, pkg-config, gtk4, gtk4-layer-shell }:

rustPlatform.buildRustPackage rec {
  pname = "hyprlauncher";
  version = "9ead5ad2f5256a26ec9311344ea7302cda187a09";

  src = fetchFromGitHub {
    owner = "joshuakb2";
    repo = pname;
    rev = version;
    hash = "sha256-5S0tgEdQcwy3xrP9VPkfmS+mdvy6P5h6mesi95jn4AM=";
  };

  cargoHash = "sha256-QfN04i4i8dx1oYH8Ir2ysMQ3mYYYwljgQ0u6jMX4uk4=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ gtk4 gtk4-layer-shell ];
  release = true;

  meta = {
    description =
      "An unofficial GUI for launching applications, built with GTK4 and Rust.";
    homepage = "https://github.com/hyprutils/hyprlauncher";
    license = lib.licenses.unlicense;
    maintainers = [ ];
  };
}
