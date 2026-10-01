# Shared by the devShell (flake.nix) and the devcontainer image (container.nix).
{ pkgs, rust }:
{
  packages = [
    rust
    pkgs.rust-analyzer

    pkgs.just
    pkgs.cargo-nextest
    pkgs.cargo-deny
    pkgs.cargo-hack
    pkgs.cargo-machete

    # oxiz-wasm
    pkgs.wasm-pack
    pkgs.wasm-bindgen-cli
    pkgs.binaryen

    # oxiz-py: tests link libpython; maturin builds wheels
    pkgs.python3
    pkgs.maturin

    pkgs.fd
    pkgs.nixfmt
  ];
}
