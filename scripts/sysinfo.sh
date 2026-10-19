#!/usr/bin/env bash
set -euo pipefail

echo "=== System Information ==="
printf 'Hostname: '
hostname

printf 'Operating system: '
uname -srm

printf 'Current UTC time: '
date -u '+%Y-%m-%d %H:%M:%S UTC'

printf '\n=== Uptime ===\n'
uptime

printf '\n=== Disk Usage ===\n'
df -h /

if command -v free >/dev/null 2>&1; then
    printf '\n=== Memory Usage ===\n'
    free -h
fi
