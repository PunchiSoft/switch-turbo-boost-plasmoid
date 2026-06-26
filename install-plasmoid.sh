#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Punchisoft
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PLASMOID_ID="org.punchisoft.switchturbo"
LOCAL_PLASMOID_DIR="${HOME}/.local/share/plasma/plasmoids/${PLASMOID_ID}"

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        printf 'Falta el comando requerido: %s\n' "$1" >&2
        exit 1
    fi
}

require_command install

if [ ! -f "$PROJECT_DIR/package/metadata.json" ]; then
    printf 'No se encontro metadata.json en %s/package\n' "$PROJECT_DIR" >&2
    exit 1
fi

printf 'Instalando plasmoide local en %s\n' "$LOCAL_PLASMOID_DIR"
rm -rf -- "$LOCAL_PLASMOID_DIR"
install -d -- "$LOCAL_PLASMOID_DIR"
cp -a -- "$PROJECT_DIR/package/." "$LOCAL_PLASMOID_DIR/"

if command -v kquitapp6 >/dev/null 2>&1 && command -v kstart6 >/dev/null 2>&1; then
    printf 'Puede reiniciar Plasma con: kquitapp6 plasmashell && kstart6 plasmashell\n'
fi
