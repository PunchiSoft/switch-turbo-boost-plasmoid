#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Punchisoft
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HELPER_DIR="/usr/local/libexec/switch-turbo-boost-plasmoid"
POLICY_FILE="/usr/share/polkit-1/actions/org.punchisoft.switchturbo.policy"

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        printf 'Falta el comando requerido: %s\n' "$1" >&2
        exit 1
    fi
}

require_command install
require_command pkexec

printf 'Instalando helpers privilegiados mediante PolicyKit...\n'
pkexec /bin/sh -c "
set -eu
install -d -m 0755 '$HELPER_DIR'
install -o root -g root -m 0755 '$PROJECT_DIR/scripts/get-cpu-info.sh' '$HELPER_DIR/get-cpu-info.sh'
install -o root -g root -m 0755 '$PROJECT_DIR/scripts/get-cpu-vendor.sh' '$HELPER_DIR/get-cpu-vendor.sh'
install -o root -g root -m 0755 '$PROJECT_DIR/scripts/get-turbo-status.sh' '$HELPER_DIR/get-turbo-status.sh'
install -o root -g root -m 0755 '$PROJECT_DIR/scripts/set-turbo-on.sh' '$HELPER_DIR/set-turbo-on.sh'
install -o root -g root -m 0755 '$PROJECT_DIR/scripts/set-turbo-off.sh' '$HELPER_DIR/set-turbo-off.sh'
install -o root -g root -m 0644 '$PROJECT_DIR/policykit/org.punchisoft.switchturbo.policy' '$POLICY_FILE'
"
