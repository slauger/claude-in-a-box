#!/usr/bin/env bash
set -euo pipefail

# With CLAUDE_CONFIG_DIR set, Claude Code keeps its global state (.claude.json:
# onboarding flag, OAuth account, project trust) inside the config dir instead
# of $HOME/.claude.json. Seed it on first start of a fresh instance so the
# onboarding flow is skipped.
config_dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
mkdir -p "$config_dir"
if [ ! -s "$config_dir/.claude.json" ]; then
  echo '{"theme":"dark","hasCompletedOnboarding":true}' > "$config_dir/.claude.json"
fi

exec claude "$@"
