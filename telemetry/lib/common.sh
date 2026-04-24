#!/usr/bin/env bash

set -euo pipefail

CC_OTEL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CC_OTEL_SIGNOZ_DIR="${CC_OTEL_ROOT}/signoz"
CC_OTEL_SIGNOZ_DEPLOY_DIR="${CC_OTEL_SIGNOZ_DIR}/docker"
CC_OTEL_BODIES_DIR="${CC_OTEL_BODIES_DIR:-/tmp/otel/claude-otel-bodies}"
CC_OTEL_LOCAL_BIN_DIR="${CC_OTEL_LOCAL_BIN_DIR:-${HOME}/.local/bin}"
CC_OTEL_CLAUDE_BIN="${CC_OTEL_CLAUDE_BIN:-}"
CC_OTEL_HEALTH_HOST="${CC_OTEL_HEALTH_HOST:-127.0.0.1}"
CC_OTEL_HEALTH_PORT="${CC_OTEL_HEALTH_PORT:-4317}"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

print_root() {
  printf '%s\n' "${CC_OTEL_ROOT}"
}

resolve_claude_bin() {
  if [[ -n "${CC_OTEL_CLAUDE_BIN}" ]]; then
    printf '%s\n' "${CC_OTEL_CLAUDE_BIN}"
    return
  fi

  local claude_bin
  claude_bin="$(command -v claude || true)"

  if [[ -z "${claude_bin}" ]]; then
    echo "Could not find claude on PATH. Set CC_OTEL_CLAUDE_BIN to the Claude Code binary." >&2
    exit 1
  fi

  printf '%s\n' "${claude_bin}"
}

otel_is_running() {
  if command -v nc >/dev/null 2>&1; then
    nc -z -G 1 "${CC_OTEL_HEALTH_HOST}" "${CC_OTEL_HEALTH_PORT}" >/dev/null 2>&1 ||
      nc -z -w 1 "${CC_OTEL_HEALTH_HOST}" "${CC_OTEL_HEALTH_PORT}" >/dev/null 2>&1
    return
  fi

  : >/dev/tcp/"${CC_OTEL_HEALTH_HOST}"/"${CC_OTEL_HEALTH_PORT}" 2>/dev/null
}

warn_if_otel_down() {
  if ! otel_is_running; then
    echo "Warning: no OTLP collector detected at ${CC_OTEL_HEALTH_HOST}:${CC_OTEL_HEALTH_PORT}. Claude will still start, but telemetry may be dropped." >&2
    echo "Start SigNoz from ${CC_OTEL_ROOT} with ./bin/signoz-up." >&2
  fi
}
