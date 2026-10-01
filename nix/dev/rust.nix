# Pinned Rust toolchain, shared by the devShell and the devcontainer image.
#
# Keep >= `rust-version` in Cargo.toml. To bump:
# 1. update `channel`,
# 2. `nix develop` — the build fails with the correct sha256,
# 3. paste it in place of the old hash.
{ fenix }:
let
  spec = {
    channel = "1.98.1";
    sha256 = "sha256-p8h3Sl/YRByZfZTAKXdsvF6xEenXKrXSVvpphmZENH4=";
  };
in
fenix.combine [
  ((fenix.toolchainOf spec).withComponents [
    "cargo"
    "clippy"
    "llvm-tools"
    "rust-src"
    "rust-std"
    "rustc"
    "rustfmt"
  ])
  # oxiz-wasm
  (fenix.targets.wasm32-unknown-unknown.toolchainOf spec).rust-std
]
