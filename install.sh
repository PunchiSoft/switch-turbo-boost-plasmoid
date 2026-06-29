#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Punchisoft
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PLASMOID_ID="org.punchisoft.switchturbo"
LOCAL_PLASMOID_DIR="${HOME}/.local/share/plasma/plasmoids/${PLASMOID_ID}"
HELPER_DIR="/usr/local/libexec/switch-turbo-boost-plasmoid"
POLICY_FILE="/usr/share/polkit-1/actions/org.punchisoft.switchturbo.policy"

INSTALL_MODE="full"
INSTALL_LANGUAGE=""
LANGUAGE_PROVIDED=0
MESSAGE_LANGUAGE=""
RELOAD_PLASMA="ask"

usage() {
    case "$(message_language)" in
        en)
            cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --full                    Install plasmoid interface and privileged backend (default)
  --plasmoid-only           Install only the local Plasma widget interface
  --backend-only            Install only privileged helpers and PolicyKit policy
  --mode full|plasmoid|backend
  --language es|en|pt|auto  Set plasmoid interface language
  --reload-plasma           Reload Plasma Shell after installing the plasmoid interface
  --no-reload-plasma        Do not ask to reload Plasma Shell
  -h, --help                Show this help

Notes:
  Full and backend-only modes install privileged helpers with PolicyKit.
  In an interactive terminal, the installer asks before reloading Plasma Shell.
  The installer does not build switch-turbo-boost.plasmoid; use ./build-plasmoid.sh for a local file install.
  Plasma reload uses KDE 6 commands when available: kquitapp6 plus kstart6/kstart,
  or plasmashell --replace as a fallback.
EOF
            ;;
        pt)
            cat <<'EOF'
Uso: ./install.sh [opcoes]

Opcoes:
  --full                    Instala a interface do plasmoide e o backend privilegiado (padrao)
  --plasmoid-only           Instala apenas a interface local do widget Plasma
  --backend-only            Instala apenas helpers privilegiados e a politica PolicyKit
  --mode full|plasmoid|backend
  --language es|en|pt|auto  Define o idioma da interface do plasmoide
  --reload-plasma           Recarrega o Plasma Shell depois de instalar a interface do plasmoide
  --no-reload-plasma        Nao pergunta se deve recarregar o Plasma Shell
  -h, --help                Mostra esta ajuda

Notas:
  Os modos full e backend-only instalam helpers privilegiados com PolicyKit.
  Em um terminal interativo, o instalador pergunta antes de recarregar o Plasma Shell.
  O instalador nao gera switch-turbo-boost.plasmoid; use ./build-plasmoid.sh para instalar a partir de arquivo local.
  A recarga do Plasma usa comandos do KDE 6 quando disponiveis: kquitapp6 com
  kstart6/kstart, ou plasmashell --replace como alternativa.
EOF
            ;;
        *)
            cat <<'EOF'
Uso: ./install.sh [opciones]

Opciones:
  --full                    Instala la interfaz del plasmoide y el backend privilegiado (predeterminado)
  --plasmoid-only           Instala solo la interfaz local del widget Plasma
  --backend-only            Instala solo helpers privilegiados y la politica PolicyKit
  --mode full|plasmoid|backend
  --language es|en|pt|auto  Define el idioma de la interfaz del plasmoide
  --reload-plasma           Recarga Plasma Shell despues de instalar la interfaz del plasmoide
  --no-reload-plasma        No pregunta si debe recargar Plasma Shell
  -h, --help                Muestra esta ayuda

Notas:
  Los modos full y backend-only instalan helpers privilegiados con PolicyKit.
  En una terminal interactiva, el instalador pregunta antes de recargar Plasma Shell.
  El instalador no genera switch-turbo-boost.plasmoid; use ./build-plasmoid.sh para instalar desde archivo local.
  La recarga de Plasma usa comandos de KDE 6 cuando estan disponibles:
  kquitapp6 con kstart6/kstart, o plasmashell --replace como alternativa.
EOF
            ;;
    esac
}

message_language() {
    if [ -n "$MESSAGE_LANGUAGE" ]; then
        printf '%s\n' "$MESSAGE_LANGUAGE"
        return
    fi

    if [ -n "$INSTALL_LANGUAGE" ] && [ "$INSTALL_LANGUAGE" != "auto" ]; then
        case "$INSTALL_LANGUAGE" in
            en|pt) printf '%s\n' "$INSTALL_LANGUAGE" ;;
            *) printf 'es\n' ;;
        esac
        return
    fi

    case "${LANG:-}" in
        en*) printf 'en\n' ;;
        pt*) printf 'pt\n' ;;
        *) printf 'es\n' ;;
    esac
}

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        case "$(message_language)" in
            en) printf 'Missing required command: %s\n' "$1" >&2 ;;
            pt) printf 'Comando obrigatorio ausente: %s\n' "$1" >&2 ;;
            *) printf 'Falta el comando requerido: %s\n' "$1" >&2 ;;
        esac
        exit 1
    fi
}

print_done() {
    case "$(message_language)" in
        en)
            case "$INSTALL_MODE" in
                full) printf '\nDone. Add "Switch Turbo Boost" to the panel from Plasma'\''s widget selector.\n' ;;
                plasmoid) printf '\nDone. The plasmoid interface was installed locally.\n' ;;
                backend) printf '\nDone. The privileged helpers and PolicyKit policy were installed.\n' ;;
            esac
            ;;
        pt)
            case "$INSTALL_MODE" in
                full) printf '\nPronto. Adicione "Switch Turbo Boost" ao painel pelo seletor de widgets do Plasma.\n' ;;
                plasmoid) printf '\nPronto. A interface do plasmoide foi instalada localmente.\n' ;;
                backend) printf '\nPronto. Os helpers privilegiados e a politica PolicyKit foram instalados.\n' ;;
            esac
            ;;
        *)
            case "$INSTALL_MODE" in
                full) printf '\nListo. Agregue "Switch Turbo Boost" al panel desde el selector de widgets de Plasma.\n' ;;
                plasmoid) printf '\nListo. La interfaz del plasmoide fue instalada localmente.\n' ;;
                backend) printf '\nListo. Los helpers privilegiados y la politica PolicyKit fueron instalados.\n' ;;
            esac
            ;;
    esac
}

print_privilege_notice() {
    case "$(message_language)" in
        en)
            printf 'The backend step installs helpers in /usr/local/libexec and a PolicyKit policy in /usr/share/polkit-1/actions.\n'
            printf 'PolicyKit will request administrator authentication before those system files are changed.\n'
            ;;
        pt)
            printf 'A etapa de backend instala helpers em /usr/local/libexec e uma politica PolicyKit em /usr/share/polkit-1/actions.\n'
            printf 'O PolicyKit solicitara autenticacao de administrador antes de alterar esses arquivos do sistema.\n'
            ;;
        *)
            printf 'El paso de backend instala helpers en /usr/local/libexec y una politica PolicyKit en /usr/share/polkit-1/actions.\n'
            printf 'PolicyKit solicitara autenticacion de administrador antes de cambiar esos archivos del sistema.\n'
            ;;
    esac
}

print_start_notice() {
    case "$INSTALL_MODE" in
        full|backend)
            case "$(message_language)" in
                en)
                    printf 'This installation includes a privileged backend step.\n'
                    printf 'PolicyKit will ask for your administrator password before installing system helpers and the policy file.\n'
                    ;;
                pt)
                    printf 'Esta instalacao inclui uma etapa de backend privilegiada.\n'
                    printf 'O PolicyKit solicitara sua senha de administrador antes de instalar os helpers do sistema e o arquivo de politica.\n'
                    ;;
                *)
                    printf 'Esta instalacion incluye un paso de backend privilegiado.\n'
                    printf 'PolicyKit pedira su contrasena de administrador antes de instalar los helpers del sistema y el archivo de politica.\n'
                    ;;
            esac
            ;;
    esac
}

set_message_language_from_current_state() {
    MESSAGE_LANGUAGE="$(message_language)"
}

install_plasmoid() {
    require_command install
    require_command sed

    if [ ! -f "$PROJECT_DIR/package/metadata.json" ]; then
        case "$(message_language)" in
            en) printf 'metadata.json was not found in %s/package\n' "$PROJECT_DIR" >&2 ;;
            pt) printf 'metadata.json nao foi encontrado em %s/package\n' "$PROJECT_DIR" >&2 ;;
            *) printf 'No se encontro metadata.json en %s/package\n' "$PROJECT_DIR" >&2 ;;
        esac
        exit 1
    fi

    case "$(message_language)" in
        en) printf 'Installing local plasmoid in %s\n' "$LOCAL_PLASMOID_DIR" ;;
        pt) printf 'Instalando plasmoide local em %s\n' "$LOCAL_PLASMOID_DIR" ;;
        *) printf 'Instalando plasmoide local en %s\n' "$LOCAL_PLASMOID_DIR" ;;
    esac

    rm -rf -- "$LOCAL_PLASMOID_DIR"
    install -d -- "$LOCAL_PLASMOID_DIR"
    cp -a -- "$PROJECT_DIR/package/." "$LOCAL_PLASMOID_DIR/"

    sed -i "/<entry name=\"uiLanguage\"/,/<\\/entry>/s#<default>[^<]*</default>#<default>${INSTALL_LANGUAGE}</default>#" "$LOCAL_PLASMOID_DIR/contents/config/main.xml"

    case "$(message_language)" in
        en) printf 'Selected interface language: %s\n' "$INSTALL_LANGUAGE" ;;
        pt) printf 'Idioma da interface selecionado: %s\n' "$INSTALL_LANGUAGE" ;;
        *) printf 'Idioma de interfaz seleccionado: %s\n' "$INSTALL_LANGUAGE" ;;
    esac
}

install_backend() {
    require_command install
    require_command pkexec

    case "$(message_language)" in
        en) printf 'Installing privileged helpers through PolicyKit...\n' ;;
        pt) printf 'Instalando helpers privilegiados via PolicyKit...\n' ;;
        *) printf 'Instalando helpers privilegiados mediante PolicyKit...\n' ;;
    esac

    if ! pkexec /bin/sh -c "
set -eu
install -d -m 0755 '$HELPER_DIR'
install -o root -g root -m 0755 '$PROJECT_DIR/scripts/get-cpu-info.sh' '$HELPER_DIR/get-cpu-info.sh'
install -o root -g root -m 0755 '$PROJECT_DIR/scripts/get-cpu-vendor.sh' '$HELPER_DIR/get-cpu-vendor.sh'
install -o root -g root -m 0755 '$PROJECT_DIR/scripts/get-turbo-status.sh' '$HELPER_DIR/get-turbo-status.sh'
install -o root -g root -m 0755 '$PROJECT_DIR/scripts/set-turbo-on.sh' '$HELPER_DIR/set-turbo-on.sh'
install -o root -g root -m 0755 '$PROJECT_DIR/scripts/set-turbo-off.sh' '$HELPER_DIR/set-turbo-off.sh'
install -o root -g root -m 0644 '$PROJECT_DIR/policykit/org.punchisoft.switchturbo.policy' '$POLICY_FILE'
"; then
        case "$(message_language)" in
            en)
                printf '\nInstallation canceled or authentication failed during the privileged backend step.\n' >&2
                if [ "$INSTALL_MODE" = "full" ]; then
                    printf 'The local plasmoid interface was installed, but the ON/OFF button will not work until the backend is installed.\n' >&2
                    printf 'Run again with: ./install.sh --backend-only\n' >&2
                else
                    printf 'The helpers and PolicyKit policy were not installed.\n' >&2
                fi
                ;;
            pt)
                printf '\nInstalacao cancelada ou autenticacao falhou durante a etapa privilegiada do backend.\n' >&2
                if [ "$INSTALL_MODE" = "full" ]; then
                    printf 'A interface local do plasmoide foi instalada, mas o botao ON/OFF nao funcionara ate instalar o backend.\n' >&2
                    printf 'Execute novamente com: ./install.sh --backend-only\n' >&2
                else
                    printf 'Os helpers e a politica PolicyKit nao foram instalados.\n' >&2
                fi
                ;;
            *)
                printf '\nInstalacion cancelada o autenticacion fallida durante el paso privilegiado del backend.\n' >&2
                if [ "$INSTALL_MODE" = "full" ]; then
                    printf 'La interfaz local del plasmoide fue instalada, pero el boton ON/OFF no funcionara hasta instalar el backend.\n' >&2
                    printf 'Ejecute nuevamente: ./install.sh --backend-only\n' >&2
                else
                    printf 'No se instalaron los helpers ni la politica PolicyKit.\n' >&2
                fi
                ;;
        esac
        exit 1
    fi
}

print_reload_skipped() {
    case "$(message_language)" in
        en)
            printf 'Plasma reload was requested, but backend-only mode does not install the plasmoid interface.\n'
            ;;
        pt)
            printf 'A recarga do Plasma foi solicitada, mas o modo backend-only nao instala a interface do plasmoide.\n'
            ;;
        *)
            printf 'Se solicito recargar Plasma, pero el modo backend-only no instala la interfaz del plasmoide.\n'
            ;;
    esac
}

reload_plasma_shell() {
    if ! command -v kquitapp6 >/dev/null 2>&1; then
        case "$(message_language)" in
            en) printf 'Could not reload Plasma automatically: kquitapp6 was not found. Log out and log in again if the widget does not update.\n' ;;
            pt) printf 'Nao foi possivel recarregar o Plasma automaticamente: kquitapp6 nao foi encontrado. Encerre a sessao e entre novamente se o widget nao atualizar.\n' ;;
            *) printf 'No se pudo recargar Plasma automaticamente: no se encontro kquitapp6. Cierre sesion e inicie nuevamente si el widget no se actualiza.\n' ;;
        esac
        return 0
    fi

    case "$(message_language)" in
        en) printf 'Reloading Plasma Shell...\n' ;;
        pt) printf 'Recarregando Plasma Shell...\n' ;;
        *) printf 'Recargando Plasma Shell...\n' ;;
    esac

    kquitapp6 plasmashell >/dev/null 2>&1 || true

    if command -v kstart6 >/dev/null 2>&1 && kstart6 plasmashell >/dev/null 2>&1; then
        return 0
    fi

    if command -v kstart >/dev/null 2>&1 && kstart plasmashell >/dev/null 2>&1; then
        return 0
    fi

    if command -v plasmashell >/dev/null 2>&1; then
        nohup plasmashell --replace >/tmp/plasmashell.log 2>&1 &
        return 0
    fi

    case "$(message_language)" in
        en) printf 'Plasma was stopped, but no kstart6, kstart, or plasmashell command was found to start it again.\n' ;;
        pt) printf 'O Plasma foi parado, mas nenhum comando kstart6, kstart ou plasmashell foi encontrado para inicia-lo novamente.\n' ;;
        *) printf 'Plasma se detuvo, pero no se encontro kstart6, kstart ni plasmashell para iniciarlo nuevamente.\n' ;;
    esac
    return 1
}

ask_reload_plasma_shell() {
    if [ "$INSTALL_MODE" = "backend" ]; then
        print_reload_skipped
        return 0
    fi

    if [ "$RELOAD_PLASMA" = "yes" ]; then
        reload_plasma_shell
        return
    fi

    if [ "$RELOAD_PLASMA" = "no" ] || [ ! -t 0 ]; then
        return 0
    fi

    case "$(message_language)" in
        en) printf 'Reload Plasma Shell now so KDE detects the widget changes? [y/N]: ' ;;
        pt) printf 'Recarregar o Plasma Shell agora para que o KDE detecte as mudancas do widget? [s/N]: ' ;;
        *) printf 'Desea recargar Plasma Shell ahora para que KDE detecte los cambios del widget? [s/N]: ' ;;
    esac
    read -r RELOAD_REPLY

    case "$RELOAD_REPLY" in
        y|Y|yes|YES|s|S|si|SI|sí|SÍ|sim|SIM)
            reload_plasma_shell
            ;;
    esac
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --full|full)
            INSTALL_MODE="full"
            ;;
        --plasmoid-only|plasmoid)
            INSTALL_MODE="plasmoid"
            ;;
        --backend-only|backend)
            INSTALL_MODE="backend"
            ;;
        --mode)
            shift
            if [ "$#" -eq 0 ]; then
                printf 'Falta el valor para --mode.\n' >&2
                usage >&2
                exit 1
            fi
            INSTALL_MODE="${1:-}"
            ;;
        --mode=*)
            INSTALL_MODE="${1#*=}"
            ;;
        --language)
            LANGUAGE_PROVIDED=1
            shift
            if [ "$#" -eq 0 ]; then
                printf 'Falta el valor para --language.\n' >&2
                usage >&2
                exit 1
            fi
            INSTALL_LANGUAGE="${1:-}"
            ;;
        --language=*)
            LANGUAGE_PROVIDED=1
            INSTALL_LANGUAGE="${1#*=}"
            ;;
        --reload-plasma)
            RELOAD_PLASMA="yes"
            ;;
        --no-reload-plasma)
            RELOAD_PLASMA="no"
            ;;
        es|en|pt|auto)
            LANGUAGE_PROVIDED=1
            INSTALL_LANGUAGE="$1"
            ;;
        *)
            printf 'Opcion no reconocida: %s\n' "$1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

case "$INSTALL_MODE" in
    full|plasmoid|backend)
        ;;
    *)
        printf 'Modo no valido: %s\n' "$INSTALL_MODE" >&2
        usage >&2
        exit 1
        ;;
esac

set_message_language_from_current_state
print_start_notice

if [ "$INSTALL_MODE" != "backend" ]; then
    if [ "$LANGUAGE_PROVIDED" -eq 0 ] && [ -t 0 ]; then
        printf 'Idioma de la interfaz / Interface language / Idioma da interface [es/en/pt/auto] (es): '
        read -r INSTALL_LANGUAGE
    fi

    INSTALL_LANGUAGE="${INSTALL_LANGUAGE:-es}"
else
    INSTALL_LANGUAGE="${INSTALL_LANGUAGE:-auto}"
fi

case "$INSTALL_LANGUAGE" in
    es|en|pt|auto)
        ;;
    *)
        printf 'Idioma no valido: %s\n' "$INSTALL_LANGUAGE" >&2
        printf 'Use es, en, pt o auto.\n' >&2
        exit 1
        ;;
esac

export SWITCH_TURBO_INSTALLER_LANGUAGE
SWITCH_TURBO_INSTALLER_LANGUAGE="$(message_language)"

case "$INSTALL_MODE" in
    full)
        install_plasmoid
        print_privilege_notice
        install_backend
        ;;
    plasmoid)
        install_plasmoid
        ;;
    backend)
        print_privilege_notice
        install_backend
        ;;
esac

print_done

ask_reload_plasma_shell
