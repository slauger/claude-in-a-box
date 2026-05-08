# 🏖️ claude-sandbox

Isolated Docker container for running [Claude Code](https://docs.anthropic.com/en/docs/claude-code) autonomously — without risking your host machine.

Built on NixOS for reproducible, declarative package management. All tools pinned, all versions explicit.

## ✨ Features

- 🐳 **Fully containerized** — Claude runs in Docker, your Mac stays safe
- 📦 **Nix-based toolchain** — reproducible builds, no version drift
- 🔒 **Non-root** — runs as unprivileged user `claude` (UID 1000)
- 🔀 **Multiple instances** — run parallel sessions with `NAME=`
- 🔑 **Credential passthrough** — SSH keys, Git config, GitHub CLI auth mounted read-only
- 💾 **Shared caches** — Go module cache shared across instances
- 📂 **Per-instance workspaces** — each session gets its own isolated workspace

## 🛠️ Included Tools

| Category | Tools |
|----------|-------|
| Languages | Python 3.13, Go 1.26, Node.js 22 |
| Kubernetes | kubectl, Helm, controller-gen |
| Go Tooling | golangci-lint, govulncheck |
| Git | git, git-lfs, gh (GitHub CLI), openssh |
| CLI | ripgrep, jq, curl, wget, make, grep, sed, awk, tar, find, ... |
| AI | Claude Code CLI |

## 🚀 Usage

### Build

```bash
make build
```

### Run

```bash
# Random instance name
make run

# Named instance
make run NAME=openvox

# Multiple parallel sessions
make run NAME=backend   # Terminal 1
make run NAME=frontend  # Terminal 2
```

### List running instances

```bash
make list
```

## ⚙️ Authentication

Create a `.env` file with one of:

```bash
# Option A: API Key (Console billing)
ANTHROPIC_API_KEY=sk-ant-...

# Option B: OAuth Token (Subscription — Pro/Max/Teams)
# Generate with: claude setup-token
CLAUDE_CODE_OAUTH_TOKEN=sk-ant-oat01-...
```

## 📁 Directory Structure

```
claude-sandbox/
├── Dockerfile          # Container definition (nixos/nix base)
├── packages.nix        # Nix package list (single source of truth)
├── Makefile            # Build & run interface
├── .env                # Auth credentials (gitignored)
└── data/               # Persistent data (gitignored)
    ├── shared/
    │   └── go/         # Go module cache (shared across instances)
    └── instances/
        └── <name>/
            └── workspace/  # Per-instance working directory
```

### Volume Mounts

| Source (Host) | Target (Container) | Mode |
|---------------|-------------------|------|
| `~/.claude` | `/home/claude/.claude` | read-write |
| `~/.ssh` | `/home/claude/.ssh` | read-only |
| `~/.gitconfig` | `/home/claude/.gitconfig` | read-only |
| `~/.config/gh` | `/home/claude/.config/gh` | read-only |
| `data/shared/go` | `/home/claude/go` | read-write |
| `data/instances/<name>/workspace` | `/home/claude/workspace` | read-write |

## 🚧 Known Issues / TODO

- ❌ **Interactive mode onboarding** — Claude Code shows the onboarding flow (color picker, login) in interactive mode even with valid `CLAUDE_CODE_OAUTH_TOKEN`. Non-interactive mode (`-p`) works fine. Upstream issue: [anthropics/claude-code#22066](https://github.com/anthropics/claude-code/issues/22066)
- ❌ **OAuth persistence in Docker** — OAuth tokens from `claude login` don't persist between container restarts. Use `CLAUDE_CODE_OAUTH_TOKEN` or `ANTHROPIC_API_KEY` via `.env` instead.
- ⚠️ **Image size** — Nix store makes the image large (~3-4 GB). Acceptable for a dev tool, but not minimal.
- ⚠️ **nixpkgs channel pinning** — currently pulls `nixpkgs` latest, which may change between builds. Consider pinning to a specific commit for full reproducibility.
- 💡 **Kubernetes manifests** — not yet implemented. Docker is sufficient for solo use; K8s manifests can be added later for multi-user/scheduled workloads.

## 📄 License

MIT
