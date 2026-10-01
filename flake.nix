{
  description = "OxiZ — pure-Rust SMT solver";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      fenix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        rust = import ./nix/dev/rust.nix { fenix = fenix.packages.${system}; };
        toolchain = import ./nix/dev/tools.nix { inherit pkgs rust; };
        devcontainerImage = import ./nix/dev/container.nix { inherit pkgs toolchain; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = toolchain.packages ++ [ pkgs.devcontainer ];
          shellHook = ''
            echo "oxiz devShell — rust $(rustc --version | cut -d' ' -f2), via fenix" >&2
          '';
        };

        formatter = pkgs.nixfmt;

        packages = {
          inherit devcontainerImage;
          default = devcontainerImage;
        };
      }
    );
}
