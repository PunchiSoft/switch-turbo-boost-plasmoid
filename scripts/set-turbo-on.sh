#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Punchisoft
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

BOOST_PATH="/sys/devices/system/cpu/cpufreq/boost"
INTEL_NO_TURBO_PATH="/sys/devices/system/cpu/intel_pstate/no_turbo"

if [[ -w "$BOOST_PATH" ]]; then
    printf '1\n' > "$BOOST_PATH"
elif [[ -w "$INTEL_NO_TURBO_PATH" ]]; then
    printf '0\n' > "$INTEL_NO_TURBO_PATH"
else
    printf 'No se puede escribir el control de Turbo Boost.\n' >&2
    exit 1
fi

printf 'Turbo Boost activado.\n'
