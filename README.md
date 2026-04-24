# productive-claude

Scripts and tools for getting more out of Claude Code.

## Projects

### [telemetry](./telemetry/)

Local observability for Claude Code using SigNoz and OpenTelemetry. Captures logs, metrics, traces, prompts, tool calls, and raw API bodies — all stored locally.

### [repo-skill-manager](./repo-skill-manager/)

Manage Claude Code context on shared repos. Team skills in `.claude/skills/` are loaded into every session — each skill's name and description gets injected into the system prompt, adding ~2,000 tokens of overhead with 20+ skills. This tool lets you toggle them on and off locally without affecting git, so you only pay for the skills you're actively using.
