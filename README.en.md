<!--
SPDX-FileCopyrightText: 2026 Punchisoft
SPDX-License-Identifier: GPL-3.0-or-later
-->

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
├── install-plasmoid.sh
├── install-backend.sh
├── uninstall.sh
├── INSTALL.md
├── README.md
└── install.sh
```

## Installation

For a step-by-step guide, see `INSTALL.en.md`.

### Installation Scripts

The project separates the plasmoid interface from the system helpers:

| Script | What it does | When to use it |
| --- | --- | --- |
| `install-plasmoid.sh` | Installs only the QML interface in `~/.local/share/plasma/plasmoids/org.punchisoft.switchturbo/`. | Use it after changing files in `package/`, such as QML, icons, text, language, settings, or metadata. |
| `install-backend.sh` | Installs the scripts from `scripts/` in `/usr/local/libexec/switch-turbo-boost-plasmoid/` and the PolicyKit policy in `/usr/share/polkit-1/actions/org.punchisoft.switchturbo.policy`. | Use it after changing the Bash helpers or the PolicyKit policy. Requires authentication through `pkexec`. |
| `install.sh` | Runs `install-plasmoid.sh` and then `install-backend.sh`. | Use it for a full installation or to update the interface, backend, and PolicyKit policy in one pass. |
| `uninstall.sh` | Removes the local plasmoid, system helpers, and PolicyKit policy. | Use it to completely uninstall the project. |

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

**Warning:** visual installation only installs the plasmoid interface. For the ON/OFF button to work with system permissions, also run:

```bash
chmod +x install-backend.sh scripts/*.sh
./install-backend.sh
```

### Full Installation by Script

From this directory:

```bash
chmod +x install.sh install-plasmoid.sh install-backend.sh scripts/*.sh
./install.sh
```

During the plasmoid installation step, you can choose the interface language. You can also pass it explicitly:

```bash
./install.sh --language en
./install.sh --language es
./install.sh --language auto
./install-plasmoid.sh --language en
./install-plasmoid.sh --language es
./install-plasmoid.sh --language auto
```

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

Then add **Switch Turbo Boost** to the panel from Plasma's widget selector. If it does not appear immediately, see **Reload Plasma Shell**.

## Reload Plasma Shell

After installing or updating the plasmoid, you may need to reload Plasma Shell so KDE detects widget changes.

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

Then restart Plasma if the widget was still loaded.

## License

Copyright 2026 Punchisoft.

Distributed under GPL-3.0-or-later. See `LICENSES/GPL-3.0-or-later.txt`.

The processor icons in `package/contents/images/` are based on Papirus Icon Theme by the Papirus Development Team:

- Source: https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
- License: GPL-3.0-only, see `LICENSES/GPL-3.0-only.txt` and the `.license` files next to each SVG.

## Warning

Changing Turbo Boost may affect performance, power consumption, temperature, and system noise. Use this plasmoid only if you understand the expected effect on your hardware.
