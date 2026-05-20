#!/usr/bin/env bash
set -euo pipefail

LABEL="com.$(whoami).claude-rc"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

if [[ ! -f "$PLIST" ]]; then
    echo "nothing to uninstall: $PLIST not found"
    exit 0
fi

launchctl unload "$PLIST" 2>/dev/null || true
rm "$PLIST"

echo "uninstalled: $PLIST"
