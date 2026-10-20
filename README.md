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
            ├── claude/     # Claude Code state (CLAUDE_CONFIG_DIR, incl. .claude.json)
            └── workspace/  # Per-instance working directory
```

### Volume Mounts

| Source (Host) | Target (Container) | Mode |
|---------------|-------------------|------|
| `data/instances/<name>/claude` | `/home/claude/.claude` | read-write |
| `~/.claude/CLAUDE.md` (if present) | `/home/claude/.claude/CLAUDE.md` | read-only |
| `~/.ssh` | `/home/claude/.ssh` | read-only |
| `~/.gitconfig` | `/home/claude/.gitconfig` | read-only |
| `~/.config/gh` | `/home/claude/.config/gh` | read-only |
| `data/shared/go` | `/home/claude/go` | read-write |
| `data/instances/<name>/workspace` | `/home/claude/workspace` | read-write |

### State persistence

Claude Code keeps its global state in `~/.claude.json` — *outside* of `~/.claude`. The image sets `CLAUDE_CONFIG_DIR=/home/claude/.claude`, which moves that file into the mounted config directory, so onboarding, login (`.credentials.json`), history and project trust survive container restarts. On first start of a new instance the entrypoint seeds `.claude.json` to skip the onboarding flow.

Each instance gets its own config directory because all instances use the same working directory path (`/home/claude/workspace`) — a shared directory would mix up session history and project memory. Reuse a `NAME=` to resume an instance.

## 🚧 Known Issues / TODO

- ⚠️ **Image size** — Nix store makes the image large (~3-4 GB). Acceptable for a dev tool, but not minimal.
- ⚠️ **nixpkgs channel pinning** — currently pulls `nixpkgs` latest, which may change between builds. Consider pinning to a specific commit for full reproducibility.
- 💡 **Kubernetes manifests** — not yet implemented. Docker is sufficient for solo use; K8s manifests can be added later for multi-user/scheduled workloads.

## 📄 License

MIT
