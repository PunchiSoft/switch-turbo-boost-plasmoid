<!--
SPDX-FileCopyrightText: 2026 Punchisoft
SPDX-License-Identifier: GPL-3.0-or-later
-->

[English](INSTALL.md) | [Español](INSTALL.es.md) | [Português](INSTALL.pt.md)

# Installing Switch Turbo Boost Plasmoid

Quick guide for installing the plasmoid on the KDE Plasma 6 desktop.

## 1. Download the Project

From Git:

```bash
git clone https://github.com/PunchiSoft/switch-turbo-boost-plasmoid.git
cd switch-turbo-boost-plasmoid
```

If you already have the code locally:

```bash
cd switch-turbo-boost-plasmoid
```

## What Each Script Does

| Script | What it installs or removes | Recommended use |
| --- | --- | --- |
| `install.sh` | Main installer. It can install everything, only the plasmoid, or only the backend. | Recommended for end users. |
| `uninstall.sh` | Removes the local plasmoid, system helpers, and PolicyKit policy. | Use it to completely uninstall the project. |
| `build-plasmoid.sh` | Generates `switch-turbo-boost.plasmoid`. | Use it only for visual installation from a local file. |

## Visual Installation From KDE Plasma

This option installs only the plasmoid interface from a local file.

### 1. Generate the .plasmoid File

```bash
chmod +x build-plasmoid.sh
./build-plasmoid.sh
```

This creates `switch-turbo-boost.plasmoid` from the `package/` directory. The file contains `metadata.json` at the package root and does not include the `package/` directory inside the zip.

### 2. Install From Plasma

1. Open Plasma.
2. Add Widgets.
3. Install Widget From Local File.
4. Select `switch-turbo-boost.plasmoid`.

**Warning:** visual installation only installs the plasmoid interface. For the ON/OFF button to work with system permissions, also run:

```bash
chmod +x install.sh
./install.sh --backend-only
```

During this step, PolicyKit will request administrator authentication.

## Full Installation by Script

### 1. Grant Execution Permissions

```bash
chmod +x install.sh
```

### 2. Run the Installer

```bash
./install.sh
```

During the plasmoid installation step, choose the interface language when prompted. You can also pass the language explicitly:

```bash
./install.sh --language en
./install.sh --language es
./install.sh --language pt
./install.sh --language auto
```

You can also choose which part to install:

```bash
./install.sh --full --language en
./install.sh --plasmoid-only --language pt
./install.sh --backend-only
./install.sh --mode backend
```

To reload Plasma Shell automatically after installing or updating the interface:

```bash
./install.sh --full --language en --reload-plasma
./install.sh --plasmoid-only --reload-plasma
```

At startup, the installer warns when the selected mode includes the privileged backend. During that backend step, PolicyKit will request administrator authentication.

If authentication is canceled during a full installation, the local plasmoid interface may already be installed, but the ON/OFF button will not work until you install the backend with `./install.sh --backend-only`.

`install.sh` installs directly from the `package/` directory; it does not generate the `switch-turbo-boost.plasmoid` file. Use `build-plasmoid.sh` only when you want to install from a local file through the Plasma graphical interface.

The installer copies:

- The plasmoid to `~/.local/share/plasma/plasmoids/org.punchisoft.switchturbo/`
- The system scripts to `/usr/local/libexec/switch-turbo-boost-plasmoid/`, including `get-cpu-info.sh` and `get-cpu-vendor.sh`
- The PolicyKit policy to `/usr/share/polkit-1/actions/org.punchisoft.switchturbo.policy`

### 3. Reload Plasma Shell

After installing or updating the plasmoid, you may need to reload Plasma Shell so KDE detects widget changes.

In an interactive terminal, the installer asks whether to reload Plasma Shell at the end. You can force it with `--reload-plasma` or suppress the question with `--no-reload-plasma`; internally it tries `kquitapp6` with `kstart6` or `kstart`, and falls back to `plasmashell --replace` when needed.

#### Option 1 - Log Out and Log In Again

Logging out and back in is the safest way to fully reload Plasma without relying on terminal commands.

This option is recommended for users who do not want to use the terminal.

#### Option 2 - Use kquitapp6 + kstart

This option was tested on Fedora KDE Plasma 6. It restarts Plasma Shell without closing the whole session:

```bash
kquitapp6 plasmashell
kstart plasmashell
```

#### Option 3 - Use nohup With plasmashell --replace

Use this alternative if `kstart` is not available. `nohup` keeps Plasma from being tied to the terminal:

```bash
kquitapp6 plasmashell
nohup plasmashell --replace >/tmp/plasmashell.log 2>&1 &
```

Not all KDE systems include the same commands. If `kstart` does not exist, use the `nohup` alternative or log out.

### 4. Add the Plasmoid to the Panel

1. Right-click the Plasma panel.
2. Select **Add or Manage Widgets**.
3. Search for **Switch Turbo Boost**.
4. Drag it to the panel.

## Settings

From the plasmoid settings, you can adjust:

- Icon shown in the panel.
- Processor icon shown in the popup menu, with automatic, AMD, Intel, CPU, chip, or custom system icon options.
- Interface language.
- Popup appearance: automatic theme and custom colors.
- Preferred popup width and height.

## Test Functionality

Check status:

```bash
/usr/local/libexec/switch-turbo-boost-plasmoid/get-turbo-status.sh
```

Detect vendor:

```bash
/usr/local/libexec/switch-turbo-boost-plasmoid/get-cpu-vendor.sh
```

Detect vendor and model:

```bash
/usr/local/libexec/switch-turbo-boost-plasmoid/get-cpu-info.sh
```

Turn Turbo Boost on:

```bash
pkexec /usr/local/libexec/switch-turbo-boost-plasmoid/set-turbo-on.sh
```

Turn Turbo Boost off:

```bash
pkexec /usr/local/libexec/switch-turbo-boost-plasmoid/set-turbo-off.sh
```

## Uninstallation

```bash
chmod +x uninstall.sh
./uninstall.sh
```

Optional language and Plasma reload:

```bash
./uninstall.sh --language en --reload-plasma
./uninstall.sh --help
```

During the system cleanup step, PolicyKit will request administrator authentication before removing the helpers and policy.
If authentication is canceled, the local plasmoid interface may already be removed, but the system helpers and PolicyKit policy may remain installed.
