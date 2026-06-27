#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Punchisoft
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

cpu_info="$(cat /proc/cpuinfo 2>/dev/null || true)"
cpu_info_lower="$(printf '%s' "$cpu_info" | tr '[:upper:]' '[:lower:]')"

if grep -q 'authenticamd\|amd' <<<"$cpu_info_lower"; then
    vendor="amd"
elif grep -q 'genuineintel\|intel' <<<"$cpu_info_lower"; then
    vendor="intel"
else
    vendor="unknown"
fi

model_name="$(
    lscpu 2>/dev/null \
        | awk -F: '/Model name/ { sub(/^[[:space:]]+/, "", $2); print $2; exit }'
)"

if [ -z "$model_name" ]; then
    model_name="$(
        awk -F: '/model name/ { sub(/^[[:space:]]+/, "", $2); print $2; exit }' /proc/cpuinfo 2>/dev/null || true
    )"
fi

printf 'vendor=%s\n' "$vendor"
printf 'model=%s\n' "$model_name"
