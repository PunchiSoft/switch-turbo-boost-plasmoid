#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Punchisoft
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

"$PROJECT_DIR/install-plasmoid.sh"
"$PROJECT_DIR/install-backend.sh"

printf '\nListo. Agregue "Switch Turbo Boost" al panel desde el selector de widgets de Plasma.\n'
