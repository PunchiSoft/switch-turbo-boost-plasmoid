<!--
SPDX-FileCopyrightText: 2026 Punchisoft
SPDX-License-Identifier: GPL-3.0-or-later
-->

[English](README.md) | [Español](README.es.md) | [Português](README.pt.md)

# Switch Turbo Boost Plasmoid

Lightweight plasmoid for the KDE Plasma 6 desktop. It shows the Turbo Boost status in the panel and lets you turn it on or off with PolicyKit authentication.

This project complements Switch Turbo Monitor. It does not replace or rewrite the main application; it only provides the Turbo Boost switch.

## Features

- QML interface for Plasma 6.
- Compact panel icon.
- Popup menu with status, description, and ON/OFF control.
- Green indicator when Turbo Boost is ON.
- Gray indicator when Turbo Boost is OFF.
- Local processor icons based on Papirus Icon Theme.
- AMD, Intel, or CPU text detected from the processor.
- CPU model name below the detected vendor when available.
- Status refresh on startup, after state changes, and every 15 seconds.
- Settings for panel icon, automatic or custom processor icon, language, and popup size.
- Automatic appearance based on the Plasma theme, with optional custom colors.
- External Bash scripts to read and modify `/sys`.
- External Bash script to detect the CPU vendor from `/proc/cpuinfo`.
- State changes through `pkexec` and a dedicated PolicyKit policy.
- Does not use `sudo` from QML.

## Compatibility

- KDE Plasma 6 desktop.
- Plasma session on Wayland or X11.
- Linux with PolicyKit and `pkexec`.
- CPU/kernel with one of these controls:
  - `/sys/devices/system/cpu/cpufreq/boost`
  - `/sys/devices/system/cpu/intel_pstate/no_turbo`

## Screenshots

| Popup menu | Widget selector |
| --- | --- |
| ![Switch Turbo Boost popup menu](Images/00.png) | ![Switch Turbo Boost in the widget selector](Images/01.png) |

| Preferences | About |
| --- | --- |
| ![Switch Turbo Boost preferences](Images/02.png) | ![Switch Turbo Boost About page](Images/03.png) |

| Keyboard shortcuts |
| --- |
| ![Switch Turbo Boost keyboard shortcuts](Images/04.png) |

Project screenshots are stored in `Images/`. They are not part of the installable plasmoid package; they are included for repository documentation.

The short document for publishing the 0.2.0 update is in `docs/release-post-0.2.0.pdf`.

## Structure

```text
switch-turbo-boost-plasmoid/
├── package/metadata.json
├── package/contents/config/main.xml
├── package/contents/config/config.qml
├── package/contents/ui/main.qml
├── package/contents/ui/TurboSwitch.qml
├── package/contents/ui/config/ConfigGeneral.qml
├── package/contents/images/
│   ├── turbo-chip.svg
│   ├── vendor-amd.svg
│   ├── vendor-cpu.svg
│   └── vendor-intel.svg
├── Images/
│   ├── 00.png
│   ├── 01.png
│   ├── 02.png
│   ├── 03.png
│   └── 04.png
├── docs/
│   ├── release-post-0.2.0.html
│   └── release-post-0.2.0.pdf
├── scripts/
│   ├── get-cpu-info.sh
│   ├── get-cpu-vendor.sh
│   ├── get-turbo-status.sh
│   ├── set-turbo-on.sh
│   └── set-turbo-off.sh
├── policykit/
│   └── org.punchisoft.switchturbo.policy
├── LICENSES/
│   └── GPL-3.0-or-later.txt
├── build-plasmoid.sh
├── uninstall.sh
├── INSTALL.md
├── INSTALL.es.md
├── INSTALL.pt.md
├── README.md
├── README.es.md
├── README.pt.md
└── install.sh
```

## Installation

For a step-by-step guide, see `INSTALL.md`.

### Installer

Use `install.sh` as the single installation entry point:

| Script | What it does | When to use it |
| --- | --- | --- |
| `install.sh` | Main installer with options for full installation, plasmoid only, or backend only. | Recommended for end users. |
| `uninstall.sh` | Removes the local plasmoid, system helpers, and PolicyKit policy. | Use it to completely uninstall the project. |
| `build-plasmoid.sh` | Generates `switch-turbo-boost.plasmoid` from `package/`. | Only for visual installation from a local file. |

### Command Reference

| Command | What it does |
| --- | --- |
| `chmod +x install.sh` | Grants execution permission to the main installer. |
| `./install.sh --help` | Shows all installer options. |
| `./install.sh` | Runs the default full installation. |
| `./install.sh --full --language en` | Installs the plasmoid interface and privileged backend, using English for the interface default. |
| `./install.sh --plasmoid-only --language pt` | Installs only the local plasmoid interface. |
| `./install.sh --backend-only` | Installs only the privileged helpers and PolicyKit policy. Useful after visual `.plasmoid` installation or after canceling backend authentication. |
| `./install.sh --full --reload-plasma` | Installs everything and reloads Plasma Shell after installation. |
| `./install.sh --no-reload-plasma` | Installs without asking whether to reload Plasma Shell. |
| `chmod +x build-plasmoid.sh && ./build-plasmoid.sh` | Builds `switch-turbo-boost.plasmoid` for visual installation from KDE Plasma. |
| `chmod +x uninstall.sh` | Grants execution permission to the uninstaller. |
| `./uninstall.sh --help` | Shows all uninstaller options. |
| `./uninstall.sh --language en --reload-plasma` | Uninstalls the plasmoid, helpers, and policy, then reloads Plasma Shell. |

### Download From Git

```bash
git clone https://github.com/PunchiSoft/switch-turbo-boost-plasmoid.git
cd switch-turbo-boost-plasmoid
```

### Visual Installation From KDE Plasma

This option creates a `.plasmoid` file that can be installed from the KDE Plasma graphical interface:

```bash
chmod +x build-plasmoid.sh
./build-plasmoid.sh
```

Then:

1. Open Plasma.
2. Add Widgets.
3. Install Widget From Local File.
4. Select `switch-turbo-boost.plasmoid`.

The `switch-turbo-boost.plasmoid` file is generated from the contents of `package/`, so `metadata.json` is placed at the package root and the `package/` directory itself is not included in the zip.

**Warning:** visual installation only installs the plasmoid interface. For the ON/OFF button to work with system permissions, also install the backend:

```bash
chmod +x install.sh
./install.sh --backend-only
```

### Full Installation by Script

From this directory:

```bash
chmod +x install.sh
./install.sh
```

During the plasmoid installation step, you can choose the interface language. You can also pass it explicitly:

```bash
./install.sh --language en
./install.sh --language es
./install.sh --language pt
./install.sh --language auto
```

The installer can also choose which part to install:

```bash
./install.sh --full --language en
./install.sh --plasmoid-only --language pt
./install.sh --backend-only
```

To reload Plasma Shell automatically after installing or updating the interface, add:

```bash
./install.sh --full --language en --reload-plasma
./install.sh --plasmoid-only --reload-plasma
```

`install.sh` installs directly from `package/`; it does not generate `switch-turbo-boost.plasmoid`. Use `build-plasmoid.sh` only for visual installation from a local file.

The installer copies the QML package to:

```text
~/.local/share/plasma/plasmoids/org.punchisoft.switchturbo/
```

It also installs, through `pkexec`, the helpers to:

```text
/usr/local/libexec/switch-turbo-boost-plasmoid/
```

and the PolicyKit policy to:

```text
/usr/share/polkit-1/actions/org.punchisoft.switchturbo.policy
```

At startup, `install.sh` warns when the selected mode includes the privileged backend and explains that PolicyKit will ask for the administrator password. If authentication is canceled during a full installation, the local plasmoid interface may already be installed, but the ON/OFF button will not work until you install the backend:

```bash
./install.sh --backend-only
```

Then add **Switch Turbo Boost** to the panel from Plasma's widget selector. If it does not appear immediately, see **Reload Plasma Shell**.

## Reload Plasma Shell

After installing or updating the plasmoid, you may need to reload Plasma Shell so KDE detects widget changes.

In an interactive terminal, the installer asks whether to reload Plasma Shell at the end. You can force it with `--reload-plasma` or suppress the question with `--no-reload-plasma`; internally it tries `kquitapp6` with `kstart6` or `kstart`, and falls back to `plasmashell --replace` when needed.

### Option 1 - Log Out and Log In Again

Logging out and back in is the safest way to fully reload Plasma without relying on terminal commands.

This option is recommended for users who do not want to use the terminal.

### Option 2 - Use kquitapp6 + kstart

This option was tested on Fedora KDE Plasma 6. It restarts Plasma Shell without closing the whole session:

```bash
kquitapp6 plasmashell
kstart plasmashell
```

### Option 3 - Use nohup With plasmashell --replace

Use this alternative if `kstart` is not available. `nohup` keeps Plasma from being tied to the terminal:

```bash
kquitapp6 plasmashell
nohup plasmashell --replace >/tmp/plasmashell.log 2>&1 &
```

Not all KDE systems include the same commands. If `kstart` does not exist, use the `nohup` alternative or log out.

## Manual Tests

Check status:

```bash
/usr/local/libexec/switch-turbo-boost-plasmoid/get-turbo-status.sh
```

Turn Turbo Boost on:

```bash
pkexec /usr/local/libexec/switch-turbo-boost-plasmoid/set-turbo-on.sh
```

Turn Turbo Boost off:

```bash
pkexec /usr/local/libexec/switch-turbo-boost-plasmoid/set-turbo-off.sh
```

## Security

The QML does not write directly to `/sys` or run `sudo`. State-changing actions call `pkexec` for scripts installed in a fixed path under `/usr/local/libexec`. PolicyKit limits authorization to those specific executables.

Reading the status does not require privileges. Writing requires administrative authentication because it modifies kernel controls.

## Uninstallation

```bash
chmod +x uninstall.sh
./uninstall.sh
```

You can also choose the message language and ask the script to reload Plasma Shell after removing the widget:

```bash
./uninstall.sh --language en --reload-plasma
./uninstall.sh --help
```

During the system cleanup step, PolicyKit will request administrator authentication before removing the helpers and policy.
If authentication is canceled, the local plasmoid interface may already be removed, but the system helpers and PolicyKit policy may remain installed.

## License

Copyright 2026 Punchisoft.

Distributed under GPL-3.0-or-later. See `LICENSES/GPL-3.0-or-later.txt`.

The processor icons in `package/contents/images/` are based on Papirus Icon Theme by the Papirus Development Team:

- Source: https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
- License: GPL-3.0-only, see `LICENSES/GPL-3.0-only.txt` and the `.license` files next to each SVG.

## Warning

Changing Turbo Boost may affect performance, power consumption, temperature, and system noise. Use this plasmoid only if you understand the expected effect on your hardware.
