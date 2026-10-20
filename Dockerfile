FROM nixos/nix:latest

# Nix config: enable flakes, disable sandbox (Docker build)
RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf \
    && echo "sandbox = false" >> /etc/nix/nix.conf \
    && echo "filter-syscalls = false" >> /etc/nix/nix.conf

# Remove pre-installed packages from base image, install our environment
COPY packages.nix /tmp/packages.nix
RUN nix-env -f /tmp/packages.nix -ir

# Non-root user
RUN echo "claude:x:1000:1000:claude:/home/claude:/bin/bash" >> /etc/passwd \
    && echo "claude:x:1000:" >> /etc/group \
    && mkdir -p /home/claude/workspace /home/claude/go \
    && chown -R 1000:1000 /home/claude

USER claude
WORKDIR /home/claude

# Environment
ENV GOPATH="/home/claude/go"
ENV PATH="/home/claude/go/bin:${PATH}"
ENV HOME="/home/claude"

# Git default config
RUN git config --global init.defaultBranch main \
    && git config --global user.name "Claude Code" \
    && git config --global user.email "claude@localhost"

# Keep all Claude Code state (incl. .claude.json) inside the mounted config dir
ENV CLAUDE_CONFIG_DIR="/home/claude/.claude"
RUN mkdir -p /home/claude/.claude

COPY --chmod=755 entrypoint.sh /usr/local/bin/entrypoint.sh

WORKDIR /home/claude/workspace
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
