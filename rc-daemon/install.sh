#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LABEL="com.$(whoami).claude-rc"
PLIST_DEST="$HOME/Library/LaunchAgents/$LABEL.plist"

usage() {
    echo "Usage: $0 --working-dir <path> [--claude-bin <path>]"
    echo ""
    echo "  --working-dir   Directory claude rc runs in (required)"
    echo "  --claude-bin    Path to claude binary (default: auto-detected via 'which claude')"
    exit 1
}

WORKING_DIR=""
CLAUDE_BIN=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --working-dir) WORKING_DIR="$2"; shift 2 ;;
        --claude-bin)  CLAUDE_BIN="$2";  shift 2 ;;
        *) usage ;;
    esac
done

[[ -z "$WORKING_DIR" ]] && usage

if [[ -z "$CLAUDE_BIN" ]]; then
    CLAUDE_BIN="$(which claude 2>/dev/null || true)"
    if [[ -z "$CLAUDE_BIN" ]]; then
        echo "error: claude binary not found in PATH. Pass --claude-bin explicitly."
        exit 1
    fi
fi

if [[ ! -x "$CLAUDE_BIN" ]]; then
    echo "error: claude binary not executable at $CLAUDE_BIN"
    exit 1
fi

if [[ ! -d "$WORKING_DIR" ]]; then
    echo "error: working directory does not exist: $WORKING_DIR"
    exit 1
fi

# Run the daemon through the user's login shell so it inherits the same PATH
# and environment as an interactive terminal (brew, nvm, pnpm, .local/bin).
LOGIN_SHELL="${SHELL:-/bin/zsh}"
if [[ ! -x "$LOGIN_SHELL" ]]; then
    echo "error: login shell not executable at $LOGIN_SHELL"
    exit 1
fi

sed \
    -e "s|__USER__|$(whoami)|g" \
    -e "s|__SHELL__|$LOGIN_SHELL|g" \
    -e "s|__CLAUDE_BIN__|$CLAUDE_BIN|g" \
    -e "s|__WORKING_DIR__|$WORKING_DIR|g" \
    "$SCRIPT_DIR/com.claude-rc.plist.template" > "$PLIST_DEST"

launchctl unload "$PLIST_DEST" 2>/dev/null || true
launchctl load "$PLIST_DEST"

echo "installed: $PLIST_DEST"
echo "label:     $LABEL"
echo "shell:     $LOGIN_SHELL"
echo "binary:    $CLAUDE_BIN"
echo "workdir:   $WORKING_DIR"
echo ""
echo "Logs: /tmp/claude-rc.log  /tmp/claude-rc.err"
