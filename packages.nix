{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

pkgs.buildEnv {
  name = "claude-sandbox-env";
  paths = with pkgs; [
    # Languages & runtimes
    python313
    go_1_26
    nodejs_22

    # Kubernetes
    kubectl
    kubernetes-helm
    kubernetes-controller-tools

    # Go tools
    golangci-lint
    govulncheck

    # Git & GitHub
    git
    git-lfs
    openssh
    gh

    # CLI essentials
    ripgrep
    jq
    curl
    wget
    tree
    less
    gnumake
    findutils
    coreutils
    bashInteractive
    gnugrep
    gnused
    gawk
    gnutar
    gzip
    which
    diffutils
    patch
    file

    # TLS
    cacert

    # Claude Code
    claude-code
  ];

  # Resolve file conflicts by picking the first package in the list
  ignoreCollisions = true;
}
