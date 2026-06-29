#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Punchisoft
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

PLASMOID_ID="org.punchisoft.switchturbo"
LOCAL_PLASMOID_DIR="${HOME}/.local/share/plasma/plasmoids/${PLASMOID_ID}"
HELPER_DIR="/usr/local/libexec/switch-turbo-boost-plasmoid"
POLICY_FILE="/usr/share/polkit-1/actions/org.punchisoft.switchturbo.policy"

UNINSTALL_LANGUAGE=""
RELOAD_PLASMA="ask"

message_language() {
    if [ -n "$UNINSTALL_LANGUAGE" ] && [ "$UNINSTALL_LANGUAGE" != "auto" ]; then
        printf '%s\n' "$UNINSTALL_LANGUAGE"
        return
    fi

    case "${LANG:-}" in
        en*) printf 'en\n' ;;
        pt*) printf 'pt\n' ;;
        *) printf 'es\n' ;;
    esac
}

usage() {
    case "$(message_language)" in
        en)
            cat <<'EOF'
Usage: ./uninstall.sh [options]

Options:
  --language es|en|pt|auto  Set installer messages language
  --reload-plasma           Reload Plasma Shell after uninstalling the plasmoid interface
  --no-reload-plasma        Do not ask to reload Plasma Shell
  -h, --help                Show this help

Notes:
  Uninstalling system helpers and the PolicyKit policy requires administrator authentication through PolicyKit.
  In an interactive terminal, the uninstaller asks before reloading Plasma Shell.
  Plasma reload uses KDE 6 commands when available: kquitapp6 plus kstart6/kstart,
  or plasmashell --replace as a fallback.
EOF
            ;;
        pt)
            cat <<'EOF'
Uso: ./uninstall.sh [opcoes]

Opcoes:
  --language es|en|pt|auto  Define o idioma das mensagens do instalador
  --reload-plasma           Recarrega o Plasma Shell depois de desinstalar a interface do plasmoide
  --no-reload-plasma        Nao pergunta se deve recarregar o Plasma Shell
  -h, --help                Mostra esta ajuda

Notas:
  A remocao dos helpers do sistema e da politica PolicyKit requer autenticacao de administrador pelo PolicyKit.
  Em um terminal interativo, o desinstalador pergunta antes de recarregar o Plasma Shell.
  A recarga do Plasma usa comandos do KDE 6 quando disponiveis: kquitapp6 com
  kstart6/kstart, ou plasmashell --replace como alternativa.
EOF
            ;;
        *)
            cat <<'EOF'
Uso: ./uninstall.sh [opciones]

Opciones:
  --language es|en|pt|auto  Define el idioma de los mensajes del instalador
  --reload-plasma           Recarga Plasma Shell despues de desinstalar la interfaz del plasmoide
  --no-reload-plasma        No pregunta si debe recargar Plasma Shell
  -h, --help                Muestra esta ayuda

Notas:
  Eliminar los helpers del sistema y la politica PolicyKit requiere autenticacion de administrador mediante PolicyKit.
  En una terminal interactiva, el desinstalador pregunta antes de recargar Plasma Shell.
  La recarga de Plasma usa comandos de KDE 6 cuando estan disponibles:
  kquitapp6 con kstart6/kstart, o plasmashell --replace como alternativa.
EOF
            ;;
    esac
}

print_privilege_notice() {
    case "$(message_language)" in
        en)
            printf 'The system cleanup removes helpers from /usr/local/libexec and a PolicyKit policy from /usr/share/polkit-1/actions.\n'
            printf 'PolicyKit will request administrator authentication before those system files are changed.\n'
            ;;
        pt)
            printf 'A limpeza do sistema remove helpers de /usr/local/libexec e uma politica PolicyKit de /usr/share/polkit-1/actions.\n'
            printf 'O PolicyKit solicitara autenticacao de administrador antes de alterar esses arquivos do sistema.\n'
            ;;
        *)
            printf 'La limpieza del sistema elimina helpers de /usr/local/libexec y una politica PolicyKit de /usr/share/polkit-1/actions.\n'
            printf 'PolicyKit solicitara autenticacion de administrador antes de cambiar esos archivos del sistema.\n'
            ;;
    esac
}

print_start_notice() {
    case "$(message_language)" in
        en)
            printf 'This uninstallation removes system helpers and a PolicyKit policy.\n'
            printf 'PolicyKit will ask for your administrator password before removing those system files.\n'
            ;;
        pt)
            printf 'Esta desinstalacao remove helpers do sistema e uma politica PolicyKit.\n'
            printf 'O PolicyKit solicitara sua senha de administrador antes de remover esses arquivos do sistema.\n'
            ;;
        *)
            printf 'Esta desinstalacion elimina helpers del sistema y una politica PolicyKit.\n'
            printf 'PolicyKit pedira su contrasena de administrador antes de eliminar esos archivos del sistema.\n'
            ;;
    esac
}

print_done() {
    case "$(message_language)" in
        en) printf '\nDone. Switch Turbo Boost Plasmoid was uninstalled.\n' ;;
        pt) printf '\nPronto. Switch Turbo Boost Plasmoid foi desinstalado.\n' ;;
        *) printf '\nListo. Switch Turbo Boost Plasmoid fue desinstalado.\n' ;;
    esac
}

reload_plasma_shell() {
    if ! command -v kquitapp6 >/dev/null 2>&1; then
        case "$(message_language)" in
            en) printf 'Could not reload Plasma automatically: kquitapp6 was not found. Log out and log in again if the widget remains visible.\n' ;;
            pt) printf 'Nao foi possivel recarregar o Plasma automaticamente: kquitapp6 nao foi encontrado. Encerre a sessao e entre novamente se o widget continuar visivel.\n' ;;
            *) printf 'No se pudo recargar Plasma automaticamente: no se encontro kquitapp6. Cierre sesion e inicie nuevamente si el widget sigue visible.\n' ;;
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
    if [ "$RELOAD_PLASMA" = "yes" ]; then
        reload_plasma_shell
        return
    fi

    if [ "$RELOAD_PLASMA" = "no" ] || [ ! -t 0 ]; then
        return 0
    fi

    case "$(message_language)" in
        en) printf 'Reload Plasma Shell now so KDE removes the widget from the current session? [y/N]: ' ;;
        pt) printf 'Recarregar o Plasma Shell agora para que o KDE remova o widget da sessao atual? [s/N]: ' ;;
        *) printf 'Desea recargar Plasma Shell ahora para que KDE quite el widget de la sesion actual? [s/N]: ' ;;
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
        --language)
            shift
            if [ "$#" -eq 0 ]; then
                printf 'Falta el valor para --language.\n' >&2
                usage >&2
                exit 1
            fi
            UNINSTALL_LANGUAGE="${1:-}"
            ;;
        --language=*)
            UNINSTALL_LANGUAGE="${1#*=}"
            ;;
        --reload-plasma)
            RELOAD_PLASMA="yes"
            ;;
        --no-reload-plasma)
            RELOAD_PLASMA="no"
            ;;
        es|en|pt|auto)
            UNINSTALL_LANGUAGE="$1"
            ;;
        *)
            printf 'Opcion no reconocida: %s\n' "$1" >&2
            usage >&2
            exit 1
            ;;
    esac
    shift
done

UNINSTALL_LANGUAGE="${UNINSTALL_LANGUAGE:-auto}"

case "$UNINSTALL_LANGUAGE" in
    es|en|pt|auto)
        ;;
    *)
        printf 'Idioma no valido: %s\n' "$UNINSTALL_LANGUAGE" >&2
        printf 'Use es, en, pt o auto.\n' >&2
        exit 1
        ;;
esac

print_start_notice

if command -v kpackagetool6 >/dev/null 2>&1; then
    kpackagetool6 --type Plasma/Applet --remove "$PLASMOID_ID" >/dev/null || true
fi

case "$(message_language)" in
    en) printf 'Removing local plasmoid from %s\n' "$LOCAL_PLASMOID_DIR" ;;
    pt) printf 'Removendo plasmoide local de %s\n' "$LOCAL_PLASMOID_DIR" ;;
    *) printf 'Eliminando plasmoide local de %s\n' "$LOCAL_PLASMOID_DIR" ;;
esac
rm -rf -- "$LOCAL_PLASMOID_DIR"

if command -v pkexec >/dev/null 2>&1; then
    print_privilege_notice
    case "$(message_language)" in
        en) printf 'Removing privileged helpers and PolicyKit policy...\n' ;;
        pt) printf 'Removendo helpers privilegiados e politica PolicyKit...\n' ;;
        *) printf 'Eliminando helpers y politica PolicyKit...\n' ;;
    esac
    if ! pkexec /usr/bin/rm -rf -- "$HELPER_DIR" "$POLICY_FILE"; then
        case "$(message_language)" in
            en)
                printf '\nUninstallation canceled or authentication failed during the privileged cleanup step.\n' >&2
                printf 'The local plasmoid interface was removed, but the system helpers and PolicyKit policy may still be installed.\n' >&2
                printf 'Run again with: ./uninstall.sh\n' >&2
                ;;
            pt)
                printf '\nDesinstalacao cancelada ou autenticacao falhou durante a limpeza privilegiada.\n' >&2
                printf 'A interface local do plasmoide foi removida, mas os helpers do sistema e a politica PolicyKit podem continuar instalados.\n' >&2
                printf 'Execute novamente com: ./uninstall.sh\n' >&2
                ;;
            *)
                printf '\nDesinstalacion cancelada o autenticacion fallida durante la limpieza privilegiada.\n' >&2
                printf 'La interfaz local del plasmoide fue eliminada, pero los helpers del sistema y la politica PolicyKit pueden seguir instalados.\n' >&2
                printf 'Ejecute nuevamente: ./uninstall.sh\n' >&2
                ;;
        esac
        exit 1
    fi
else
    case "$(message_language)" in
        en) printf 'pkexec was not found. Remove these paths manually:\n%s\n%s\n' "$HELPER_DIR" "$POLICY_FILE" >&2 ;;
        pt) printf 'pkexec nao foi encontrado. Remova estes caminhos manualmente:\n%s\n%s\n' "$HELPER_DIR" "$POLICY_FILE" >&2 ;;
        *) printf 'No se encontro pkexec. Elimine manualmente:\n%s\n%s\n' "$HELPER_DIR" "$POLICY_FILE" >&2 ;;
    esac
fi

print_done

ask_reload_plasma_shell
