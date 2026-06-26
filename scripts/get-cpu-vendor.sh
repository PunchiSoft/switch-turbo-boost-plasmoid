#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Punchisoft
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

cpu_info="$(tr '[:upper:]' '[:lower:]' </proc/cpuinfo 2>/dev/null || true)"

if grep -q 'authenticamd\|amd' <<<"$cpu_info"; then
    printf 'amd\n'
elif grep -q 'genuineintel\|intel' <<<"$cpu_info"; then
    printf 'intel\n'
else
    printf 'unknown\n'
fi
