#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Punchisoft
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PLASMOID_ID="org.punchisoft.switchturbo"
LOCAL_PLASMOID_DIR="${HOME}/.local/share/plasma/plasmoids/${PLASMOID_ID}"
INSTALL_LANGUAGE=""

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        printf 'Falta el comando requerido: %s\n' "$1" >&2
        exit 1
    fi
}

require_command install
require_command sed

while [ "$#" -gt 0 ]; do
    case "$1" in
        --language)
            shift
            if [ "$#" -eq 0 ]; then
                printf 'Falta el valor para --language.\n' >&2
                printf 'Uso: %s [--language es|en|auto]\n' "$0" >&2
                exit 1
            fi
            INSTALL_LANGUAGE="${1:-}"
            ;;
        --language=*)
            INSTALL_LANGUAGE="${1#*=}"
            ;;
        es|en|auto)
            INSTALL_LANGUAGE="$1"
            ;;
        *)
            printf 'Opcion no reconocida: %s\n' "$1" >&2
            printf 'Uso: %s [--language es|en|auto]\n' "$0" >&2
            exit 1
            ;;
    esac
    shift
done

if [ -z "$INSTALL_LANGUAGE" ] && [ -t 0 ]; then
    printf 'Idioma de la interfaz / Interface language [es/en/auto] (es): '
    read -r INSTALL_LANGUAGE
fi

INSTALL_LANGUAGE="${INSTALL_LANGUAGE:-es}"

case "$INSTALL_LANGUAGE" in
    es|en|auto)
        ;;
    *)
        printf 'Idioma no valido: %s\n' "$INSTALL_LANGUAGE" >&2
        printf 'Use es, en o auto.\n' >&2
        exit 1
        ;;
esac

if [ ! -f "$PROJECT_DIR/package/metadata.json" ]; then
    printf 'No se encontro metadata.json en %s/package\n' "$PROJECT_DIR" >&2
    exit 1
fi

printf 'Instalando plasmoide local en %s\n' "$LOCAL_PLASMOID_DIR"
rm -rf -- "$LOCAL_PLASMOID_DIR"
install -d -- "$LOCAL_PLASMOID_DIR"
cp -a -- "$PROJECT_DIR/package/." "$LOCAL_PLASMOID_DIR/"

sed -i "/<entry name=\"uiLanguage\"/,/<\\/entry>/s#<default>[^<]*</default>#<default>${INSTALL_LANGUAGE}</default>#" "$LOCAL_PLASMOID_DIR/contents/config/main.xml"
printf 'Idioma de interfaz seleccionado: %s\n' "$INSTALL_LANGUAGE"

if command -v kquitapp6 >/dev/null 2>&1 && command -v kstart6 >/dev/null 2>&1; then
    printf 'Puede reiniciar Plasma con: kquitapp6 plasmashell && kstart6 plasmashell\n'
fi
