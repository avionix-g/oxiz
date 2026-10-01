# Devcontainer image: Debian FHS base + the flake toolchain at /nix-profile.
#
# The container has no Nix store of its own: devcontainer.json bind-mounts host
# /nix and talks to the host nix-daemon (NIX_REMOTE=daemon), so the
# /nix-profile symlinks resolve only because the host store holds the closure.
{
  pkgs,
  toolchain,
  claude-code,
}:
let
  baseImage = pkgs.dockerTools.pullImage {
    # Bump: nix run nixpkgs#nix-prefetch-docker -- --image-name debian --image-tag 13-slim --os linux --arch amd64
    imageName = "debian";
    imageDigest = "sha256:28de0877c2189802884ccd20f15ee41c203573bd87bb6b883f5f46362d24c5c2";
    hash = "sha256-yavN9aGELaqiddXKzUlYGw01I0zxDIBYfYJ9RqDHwLo=";
    finalImageName = "debian";
    finalImageTag = "13-slim";
    os = "linux";
    arch = "amd64";
  };

  profile = pkgs.buildEnv {
    name = "oxiz-dev-profile";
    extraPrefix = "/nix-profile";
    paths = toolchain.packages ++ [
      claude-code

      pkgs.cacert  # TLS for cargo/nix fetches
      pkgs.nix  # nix client in container
      pkgs.stdenv.cc  # debian-slim ships no compiler; same cc the devShell gets

			# General utils
			pkgs.fd
      pkgs.git
      pkgs.iputils
      pkgs.less
      pkgs.netcat
      pkgs.ripgrep
      pkgs.sd
      pkgs.tree
    ];
  };

  managedSettingsFile = pkgs.writeText "managed-settings.json" (
    builtins.toJSON {
      permissions.defaultMode = "bypassPermissions";
      enableAllProjectMcpServers = true;
      skipDangerousModePermissionPrompt = true;
    }
  );
in
pkgs.dockerTools.buildLayeredImage {
  name = "oxiz-devcontainer";
  tag = "latest";
  fromImage = baseImage;
  # Max-precedence Claude Code policy, copied into the image's own /etc layer so it survives the
  # host-/nix bind mount.
  extraCommands = ''
    mkdir -p etc/claude-code
    cp ${managedSettingsFile} etc/claude-code/managed-settings.json
    chmod 0644 etc/claude-code/managed-settings.json
  '';

  passthru = { inherit profile; };
  contents = [ profile ];

  config = {
    Env = [
      "PATH=/nix-profile/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      "SSL_CERT_FILE=/nix-profile/etc/ssl/certs/ca-bundle.crt"
      "CARGO_HOME=/root/.cargo"
      "NIX_REMOTE=daemon"
      "NIX_CONFIG=experimental-features = nix-command flakes"
      "OXIZ_DEVCONTAINER=1"
      # Claude CLI refuses bypass-permissions as root outside a sandbox
      "IS_SANDBOX=1"
      "CLAUDE_CONFIG_DIR=/home/node/.claude"
    ];
    WorkingDir = "/src";
  };
}
