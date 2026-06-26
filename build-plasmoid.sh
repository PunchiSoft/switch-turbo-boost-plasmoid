#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Punchisoft
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$PROJECT_DIR/package"
OUTPUT_FILE="$PROJECT_DIR/switch-turbo-boost.plasmoid"

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        printf 'Falta el comando requerido: %s\n' "$1" >&2
        exit 1
    fi
}

require_command zip

if [ ! -f "$PACKAGE_DIR/metadata.json" ]; then
    printf 'No se encontro metadata.json en %s\n' "$PACKAGE_DIR" >&2
    exit 1
fi

rm -f -- "$OUTPUT_FILE"

printf 'Generando %s\n' "$OUTPUT_FILE"
(
    cd -- "$PACKAGE_DIR"
    zip -r "$OUTPUT_FILE" . >/dev/null
)

printf 'Paquete creado: %s\n' "$OUTPUT_FILE"
