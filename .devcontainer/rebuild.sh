#!/usr/bin/env bash

set -e

# devcontainer-rebuild
nix build .#devcontainerImage && podman load < result
mkdir -p ~/.local/state/nix/gcroots
nix build .#devcontainerImage.profile --out-link ~/.local/state/nix/gcroots/oxiz-devcontainer-profile-{{ devcontainer-checkout-key }}

# devcontainer-reup
devcontainer up --docker-path podman --workspace-folder . --remove-existing-container
