# Shared by the devShell (flake.nix) and the devcontainer image (container.nix).
{ pkgs, rust }:
let
  # Parity baseline version (bench/z3_parity/run_parity.sh); nixpkgs tracks newer.
  z3 = pkgs.z3.overrideAttrs (_: {
    version = "4.15.4";
    src = pkgs.fetchFromGitHub {
      owner = "Z3Prover";
      repo = "z3";
      rev = "z3-4.15.4";
      hash = "sha256-eyF3ELv81xEgh9Km0Ehwos87e4VJ82cfsp53RCAtuTo=";
    };
  });
in
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

    # scripts/perf_vs_z3.sh, bench/z3_parity/run_parity.sh: baseline pinned by the script
    z3

    # scripts/flamegraph.sh
    pkgs.cargo-flamegraph
    pkgs.inferno
    pkgs.linuxPackages.perf

    # scripts/pgo_build.sh (llvm-profdata)
    pkgs.llvm

    # oxiz-vscode
    pkgs.nodejs

    pkgs.fd
    pkgs.nixfmt
  ];
}
