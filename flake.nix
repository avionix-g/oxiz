{
  description = "OxiZ — pure-Rust SMT solver";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      fenix,
      claude-code,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        rust = import ./nix/dev/rust.nix { fenix = fenix.packages.${system}; };
        toolchain = import ./nix/dev/tools.nix { inherit pkgs rust; };
        claude = claude-code.packages.${system}.claude-code;
        devcontainerImage = import ./nix/dev/container.nix {
          inherit pkgs toolchain;
          claude-code = claude;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = toolchain.packages ++ [
            claude
            # Host-side launcher; not in tools.nix, which also feeds the image.
            pkgs.devcontainer
          ];
          shellHook = ''
            echo "oxiz devShell — rust $(rustc --version | cut -d' ' -f2), via fenix" >&2
          '';
        };

        # `cargo fuzz` needs nightly: `nix develop .#fuzz`
        devShells.fuzz = pkgs.mkShell {
          packages = [
            fenix.packages.${system}.complete.toolchain
            pkgs.cargo-fuzz
            pkgs.stdenv.cc
          ];
        };

        formatter = pkgs.nixfmt;

        packages = {
          inherit devcontainerImage;
          default = devcontainerImage;
        };
      }
    );
}
