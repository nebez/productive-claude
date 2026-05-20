# rc-daemon

Keeps a `claude rc` session alive as a macOS LaunchAgent, wrapped in `caffeinate` so the machine never sleeps and kills it.

This is what makes Claude Code's [remote control](https://docs.anthropic.com/en/docs/claude-code/remote-claude-code) feature persistent across reboots and wake/sleep cycles.

## Install

```bash
./rc-daemon/install.sh --working-dir /path/to/your/repo
```

The script auto-detects the `claude` binary from your PATH. If it lives somewhere unusual (e.g. `~/.pnpm/claude`), pass it explicitly:

```bash
./rc-daemon/install.sh --working-dir /path/to/your/repo --claude-bin ~/.pnpm/claude
```

This writes `~/Library/LaunchAgents/com.<you>.claude-rc.plist`, loads it, and starts it immediately.

Logs go to `/tmp/claude-rc.log` and `/tmp/claude-rc.err`.

## Uninstall

```bash
./rc-daemon/uninstall.sh
```

Unloads the agent and removes the plist.

## Status

```bash
launchctl list | grep claude-rc
```

A PID in the first column means it's running. A `-` means it stopped (check `/tmp/claude-rc.err`).
