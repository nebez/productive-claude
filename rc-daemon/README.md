# rc-daemon

Keeps a `claude rc` session alive as a macOS LaunchAgent, wrapped in `caffeinate` so the machine never sleeps and kills it.

This is what makes Claude Code's [remote control](https://docs.anthropic.com/en/docs/claude-code/remote-claude-code) feature persistent across reboots and wake/sleep cycles.

## Environment

launchd starts agents with a bare environment (`PATH=/usr/bin:/bin:...`, no shell rc sourced). Run directly, `claude rc` and every command it shells out to get that stripped PATH, so Claude can't find `node`, `pnpm`, `brew`, or anything installed under `$HOME`.

The plist works around this by running through your login shell: `zsh -lic 'exec caffeinate ... claude rc ...'`. The `-l` sources `.zprofile`, the `-i` sources `.zshrc`, so the session inherits the same PATH and env as your terminal. `exec` replaces the shell with caffeinate so `KeepAlive` tracks the real process with nothing left dangling.

If your PATH lives somewhere a login+interactive shell won't source (a non-default rc file, a different shell), the daemon won't see it either. The install script uses `$SHELL`; override by editing the generated plist.

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
