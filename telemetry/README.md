# 📡 telemetry

Local observability for Claude Code using [SigNoz](https://signoz.io/) and OpenTelemetry.

Captures logs, metrics, traces, user prompts, tool calls, and raw API request/response bodies — all stored locally. Nothing leaves your machine.

## Quick Start

```bash
# 1. Start the SigNoz stack (Docker required)
./telemetry/bin/signoz-up

# 2. Symlink the Claude launchers into ~/.local/bin
./telemetry/bin/link-local-bin

# 3. Use Claude as usual — telemetry flows automatically
cclaude          # uses your normal claude.ai login
cbedrock         # uses AWS Bedrock (defaults to AWS_PROFILE=dev, AWS_REGION=us-east-1)
```

SigNoz UI: [http://localhost:7777](http://localhost:7777) (no login required).

## Launchers

| Command | Backend | Notes |
|---------|---------|-------|
| `cclaude` | claude.ai | Unsets all Anthropic/Bedrock env vars so Claude uses your normal login |
| `cbedrock` | AWS Bedrock | Override with `AWS_PROFILE=prod cbedrock` |

Both launchers enable full OTEL export (logs, metrics, traces, prompts, tool content, raw API bodies) and warn if SigNoz isn't running.

## Managing SigNoz

```bash
./telemetry/bin/signoz-up      # start
./telemetry/bin/signoz-down    # stop (preserves data)
./telemetry/bin/signoz-ps      # container status
./telemetry/bin/signoz-logs    # tail logs
```

Containers use `restart: "no"` — they won't auto-start with Docker.

## Uninstalling

To stop using the launchers, just remove the symlinks:

```bash
rm ~/.local/bin/cclaude ~/.local/bin/cbedrock
```

To nuke everything (containers, volumes, temp files):

```bash
./telemetry/bin/signoz-nuke
```

Prompts for confirmation before deleting Docker volumes and `/tmp/otel/claude-otel-bodies`.
