# Fedora Hyprland + Caelestia Topbar Setup

A reproducible Fedora setup for Hyprland with a customized Caelestia Shell top bar.

This repo is intended to let me take a fresh Fedora installation, clone this repo, run one installer, and restore the same Hyprland + Caelestia workflow.

## What this setup includes

- Fedora + Hyprland
- Quickshell
- Caelestia Shell
- Caelestia PR #1748 for horizontal/top-bar support
- Custom Caelestia build installed in the user account
- Top bar shown only on the main monitor
- Caelestia casing/borders removed from secondary monitors
- Workspace indicators removed from the top bar
- Fedora/Caelestia logo removed from the top bar
- Active-window title centered on the physical monitor
- Per-monitor workspace groups
- Custom Hyprland keybindings
- Custom workspace switching script
- Caelestia launcher support
- User-local launcher script for the customized shell
- Backup of existing configs before installation

## Current monitor layout

The saved workstation profile currently expects:

- `DP-5` — main ASUS monitor
- `DP-4` — upper monitor
- `HDMI-A-2` — lower rotated monitor

Monitor connector names can change on another machine.

Before using this setup on different hardware, check:

```bash
hyprctl monitors
```

and update the monitor configuration if necessary.

## Workspace layout

This setup uses separate workspace ranges per monitor:

- Main monitor: `1-9`
- Top monitor: `11-19`
- Bottom monitor: `21-29`

The custom workspace helper maps the local workspace number based on whichever monitor currently has focus.

Typical bindings include:

- `Alt + 1..9` — switch to that monitor's local workspace
- `Alt + Shift + 1..9` — move the focused window to that monitor's local workspace
- `Alt + Arrow Keys` — move focus
- `Alt + Shift + Arrow Keys` — move tiled windows

## Repository layout

```text
Fedora-HyprLand-Caelestia/
├── install.fish
├── bin/
│   └── caelestia-topbar
├── caelestia/
│   ├── shell.json
│   ├── shell-tokens.json
│   ├── monitors/
│   │   ├── DP-4/
│   │   │   └── shell.json
│   │   └── HDMI-A-2/
│   │       └── shell.json
│   └── patches/
│       ├── Bar.qml
│       └── ActiveWindow.qml
└── hypr/
    └── ...
```

## Fresh Fedora installation

### 1. Update Fedora

```bash
sudo dnf upgrade --refresh
```

Reboot if Fedora installs a new kernel.

### 2. Install Git

```bash
sudo dnf install git
```

### 3. Clone this repository

Using SSH:

```bash
git clone git@github.com:JakeWayneMurray/Fedora-HyprLand-Caelestia.git
cd Fedora-HyprLand-Caelestia
```

### 4. Run the installer

```fish
chmod +x install.fish
./install.fish
```

The installer is designed for Fish and installs the Fedora/COPR packages needed by this setup, restores the saved configs, clones the Caelestia Shell source, checks out PR #1748, applies the custom QML files, builds the Caelestia QML plugin, and installs it into the user account.

## Important package note

This setup uses `quickshell-git`, not Fedora's normal `quickshell` package.

Those packages conflict with each other, so the installer should install:

```text
quickshell-git
```

and should **not** request both `quickshell` and `quickshell-git`.

## COPR repositories

The setup uses Fedora COPRs including:

```text
ashbuk/Hyprland-Fedora
celestelove/caelestia
```

The Caelestia COPR also enables dependency repositories used for packages such as Quickshell, `app2unit`, and `libcava`.

## Caelestia top bar

The customized shell is based on Caelestia Shell PR #1748, which adds horizontal bar placement.

The custom shell source lives at:

```text
~/.config/quickshell/caelestia-topbar
```

The user-local QML plugin is installed under:

```text
~/.local/lib/qt6/qml
```

and the custom Caelestia libraries are installed under:

```text
~/.local/lib/caelestia-topbar
```

The launcher is:

```text
~/.local/bin/caelestia-topbar
```

Hyprland starts it using:

```text
exec-once = ~/.local/bin/caelestia-topbar
```

## Main-monitor-only top bar

The main Caelestia configuration excludes the secondary displays from the bar.

Current excluded screens:

```text
DP-4
HDMI-A-2
```

That leaves the top bar on `DP-5`.

## Secondary-monitor border removal

Per-monitor Caelestia overrides disable the border/casing on:

```text
DP-4
HDMI-A-2
```

These are stored under:

```text
caelestia/monitors/
```

and copied into:

```text
~/.config/caelestia/monitors/
```

by the installer.

## Top-bar customizations

The current top bar has been customized to:

- stay at the top
- hide workspace indicators
- hide the Fedora/Caelestia logo
- center the active-window title independently of the right-side status modules
- remain visually clean on the main monitor only

The known-good QML files are stored in:

```text
caelestia/patches/Bar.qml
caelestia/patches/ActiveWindow.qml
```

The installer copies these over the checked-out PR source before building.

## Restarting the custom shell

```bash
pkill -f caelestia-topbar/shell.qml
~/.local/bin/caelestia-topbar
```

## Returning to the packaged Caelestia shell

The Fedora RPM-installed Caelestia Shell is intentionally kept as a fallback.

To stop the custom shell:

```bash
pkill -f caelestia-topbar/shell.qml
```

Then the packaged shell can be started with:

```bash
caelestia shell -d
```

## Caffeine / disabling idle lock temporarily

This setup uses `hypridle`.

To temporarily stop idle locking:

```bash
pkill hypridle
```

To start it again:

```bash
hypridle &
```

A custom toggle script can also be bound in Hyprland for Caffeine-style behavior.

## Updating the backup after making changes

After changing the live configuration, copy the working versions back into this repository before committing.

Examples:

```bash
cp -a ~/.config/hypr/. ~/Fedora-HyprLand-Caelestia/hypr/

cp ~/.config/caelestia/shell.json \
  ~/Fedora-HyprLand-Caelestia/caelestia/

cp ~/.config/quickshell/caelestia-topbar/modules/bar/Bar.qml \
  ~/Fedora-HyprLand-Caelestia/caelestia/patches/

cp ~/.config/quickshell/caelestia-topbar/modules/bar/components/ActiveWindow.qml \
  ~/Fedora-HyprLand-Caelestia/caelestia/patches/
```

Then:

```bash
git add .
git commit -m "Update working desktop configuration"
git push
```

## Troubleshooting

### Caelestia appears on the left instead of the top

Verify:

```bash
jq '.bar.position' ~/.config/caelestia/shell.json
```

Expected:

```json
"top"
```

### Both the left and top bars are visible

Two shell instances are probably running.

Stop the packaged one:

```bash
caelestia shell -k
```

and restart only the custom one:

```bash
~/.local/bin/caelestia-topbar
```

### `bar.position` is reported as unknown

The shell is probably loading the Fedora RPM's compiled Caelestia QML plugin instead of the custom PR build.

The custom launcher sets:

```text
QML2_IMPORT_PATH=$HOME/.local/lib/qt6/qml
QML_IMPORT_PATH=$HOME/.local/lib/qt6/qml
CAELESTIA_LIB_DIR=$HOME/.local/lib/caelestia-topbar
```

Use the custom launcher rather than invoking the PR QML directly.

### Monitor layout is wrong

Run:

```bash
hyprctl monitors
```

and adjust the saved monitor connector names and positions.

## Rollback

The installer should back up existing configs before replacing them.

Backups are stored in a directory similar to:

```text
~/caelestia-preinstall-YYYYMMDD-HHMMSS
```

If something goes wrong, restore the saved `hypr`, `caelestia`, or `quickshell` directories from that backup.

## Notes

This repository is intentionally opinionated and tailored to this workstation.

The most machine-specific pieces are:

- monitor names
- monitor positions
- display resolutions
- workspace-to-monitor assignments

Everything else should be portable across compatible Fedora + Hyprland systems.
