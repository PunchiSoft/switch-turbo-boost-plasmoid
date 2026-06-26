#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Punchisoft
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

BOOST_PATH="/sys/devices/system/cpu/cpufreq/boost"
INTEL_NO_TURBO_PATH="/sys/devices/system/cpu/intel_pstate/no_turbo"

if [[ -r "$BOOST_PATH" ]]; then
    value="$(<"$BOOST_PATH")"
    case "${value//$'\n'/}" in
        1) printf 'ON\n' ;;
        0) printf 'OFF\n' ;;
        *) printf 'Valor inesperado en %s: %s\n' "$BOOST_PATH" "$value" >&2; exit 2 ;;
    esac
elif [[ -r "$INTEL_NO_TURBO_PATH" ]]; then
    value="$(<"$INTEL_NO_TURBO_PATH")"
    case "${value//$'\n'/}" in
        0) printf 'ON\n' ;;
        1) printf 'OFF\n' ;;
        *) printf 'Valor inesperado en %s: %s\n' "$INTEL_NO_TURBO_PATH" "$value" >&2; exit 2 ;;
    esac
else
    printf 'Turbo Boost no disponible en este kernel o CPU.\n' >&2
    exit 1
fi
