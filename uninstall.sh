#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Punchisoft
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

PLASMOID_ID="org.punchisoft.switchturbo"
LOCAL_PLASMOID_DIR="${HOME}/.local/share/plasma/plasmoids/${PLASMOID_ID}"
HELPER_DIR="/usr/local/libexec/switch-turbo-boost-plasmoid"
POLICY_FILE="/usr/share/polkit-1/actions/org.punchisoft.switchturbo.policy"

if command -v kpackagetool6 >/dev/null 2>&1; then
    kpackagetool6 --type Plasma/Applet --remove "$PLASMOID_ID" >/dev/null || true
fi

printf 'Eliminando plasmoide local de %s\n' "$LOCAL_PLASMOID_DIR"
rm -rf -- "$LOCAL_PLASMOID_DIR"

if command -v pkexec >/dev/null 2>&1; then
    printf 'Eliminando helpers y politica PolicyKit...\n'
    pkexec /usr/bin/rm -rf -- "$HELPER_DIR" "$POLICY_FILE"
else
    printf 'No se encontro pkexec. Elimine manualmente:\n%s\n%s\n' "$HELPER_DIR" "$POLICY_FILE" >&2
fi

if command -v kquitapp6 >/dev/null 2>&1 && command -v kstart6 >/dev/null 2>&1; then
    printf 'Puede reiniciar Plasma con: kquitapp6 plasmashell && kstart6 plasmashell\n'
fi
