<!--
SPDX-FileCopyrightText: 2026 Punchisoft
SPDX-License-Identifier: GPL-3.0-or-later
-->

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
| `install-plasmoid.sh` | Copies only the plasmoid interface from `package/` to `~/.local/share/plasma/plasmoids/org.punchisoft.switchturbo/`. | Use it after changing QML, icons, language, text, settings, or `metadata.json`. |
| `install-backend.sh` | Copies the helpers from `scripts/` to `/usr/local/libexec/switch-turbo-boost-plasmoid/` and installs the PolicyKit policy in `/usr/share/polkit-1/actions/org.punchisoft.switchturbo.policy`. | Use it after changing the Bash helpers or the PolicyKit policy. It requests permissions with `pkexec`. |
| `install.sh` | Runs `install-plasmoid.sh` first and then `install-backend.sh`. | Use it for a full installation or when you want to update everything at once. |
| `uninstall.sh` | Removes the local plasmoid, system helpers, and PolicyKit policy. | Use it to completely uninstall the project. |

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
chmod +x install-backend.sh scripts/*.sh
./install-backend.sh
```

During this step, PolicyKit will request administrator authentication.

## Full Installation by Script

### 1. Grant Execution Permissions

```bash
chmod +x install.sh install-plasmoid.sh install-backend.sh scripts/*.sh
```

### 2. Run the Installer

```bash
./install.sh
```

During the plasmoid installation step, choose the interface language when prompted. You can also pass the language explicitly:

```bash
./install.sh --language en
./install.sh --language es
./install.sh --language auto
./install-plasmoid.sh --language en
./install-plasmoid.sh --language es
./install-plasmoid.sh --language auto
```

During the backend installation step, PolicyKit will request administrator authentication.

The installer copies:

- The plasmoid to `~/.local/share/plasma/plasmoids/org.punchisoft.switchturbo/`
- The system scripts to `/usr/local/libexec/switch-turbo-boost-plasmoid/`, including `get-cpu-info.sh` and `get-cpu-vendor.sh`
- The PolicyKit policy to `/usr/share/polkit-1/actions/org.punchisoft.switchturbo.policy`

### 3. Reload Plasma Shell

After installing or updating the plasmoid, you may need to reload Plasma Shell so KDE detects widget changes.

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

If the widget was still loaded in the panel, see **Reload Plasma Shell**.
