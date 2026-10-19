#!/usr/bin/env bash
set -euo pipefail

HEALTH_URL="${1:-http://127.0.0.1:8080/healthz}"

if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: curl is required but was not found." >&2
    exit 1
fi

if curl --fail --silent --show-error --max-time 5 "$HEALTH_URL" >/dev/null; then
    echo "Health check passed: $HEALTH_URL"
else
    echo "ERROR: Health check failed: $HEALTH_URL" >&2
    exit 1
fi
