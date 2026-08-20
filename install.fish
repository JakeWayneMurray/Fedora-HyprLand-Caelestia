#!/usr/bin/env fish

set -l SETUP_DIR (realpath (dirname (status filename)))

echo "==> Fedora Hyprland/Caelestia setup"
echo "Source: $SETUP_DIR"

# ---------------------------------------------------------
# Repositories
# ---------------------------------------------------------

sudo dnf copr enable -y ashbuk/Hyprland-Fedora
sudo dnf copr enable -y celestelove/caelestia

# The Caelestia COPR already pulls its Quickshell/libcava/app2unit
# dependency repositories as needed.

# ---------------------------------------------------------
# Packages
# ---------------------------------------------------------

sudo dnf install -y \
    git \
    cmake \
    ninja-build \
    gcc-c++ \
    qt6-qtdeclarative-devel \
    qt6-qtshadertools-devel \
    libqalculate-devel \
    lm_sensors-devel \
    libcava-devel \
    cava \
    ddcutil \
    lm_sensors \
    jq \
    foot \
    nautilus \
    fastfetch \
    hyprland \
    xdg-desktop-portal-hyprland \
    quickshell-git \
    caelestia-shell \
    app2unit \
    python3-pip \
    aubio-devel
or exit 1

# ---------------------------------------------------------
# Caelestia CLI
# ---------------------------------------------------------

sudo python3 -m pip install --upgrade \
    'git+https://github.com/caelestia-dots/cli.git@v1.1.2'

or exit 1

# ---------------------------------------------------------
# Back up existing user configs
# ---------------------------------------------------------

set -l stamp (date +%Y%m%d-%H%M%S)
set -l backup "$HOME/caelestia-preinstall-$stamp"

mkdir -p "$backup"

if test -d ~/.config/hypr
    cp -a ~/.config/hypr "$backup/"
end

if test -d ~/.config/caelestia
    cp -a ~/.config/caelestia "$backup/"
end

if test -d ~/.config/quickshell/caelestia-topbar
    cp -a ~/.config/quickshell/caelestia-topbar "$backup/"
end

echo "==> Previous configs backed up to:"
echo "    $backup"

# ---------------------------------------------------------
# User config
# ---------------------------------------------------------

mkdir -p ~/.config/hypr
mkdir -p ~/.config/caelestia
mkdir -p ~/.config/quickshell
mkdir -p ~/.local/bin

cp -a "$SETUP_DIR/hypr/." ~/.config/hypr/

cp "$SETUP_DIR/caelestia/shell.json" \
    ~/.config/caelestia/shell.json

if test -f "$SETUP_DIR/caelestia/shell-tokens.json"
    cp "$SETUP_DIR/caelestia/shell-tokens.json" \
        ~/.config/caelestia/shell-tokens.json
end

cp "$SETUP_DIR/bin/caelestia-topbar" \
    ~/.local/bin/caelestia-topbar

chmod +x ~/.local/bin/caelestia-topbar

if test -f ~/.config/hypr/scripts/wsaction.fish
    chmod +x ~/.config/hypr/scripts/wsaction.fish
end

# ---------------------------------------------------------
# Caelestia shell PR #1748
# ---------------------------------------------------------

rm -rf ~/.config/quickshell/caelestia-topbar

git clone \
    https://github.com/caelestia-dots/shell.git \
    ~/.config/quickshell/caelestia-topbar

or exit 1

cd ~/.config/quickshell/caelestia-topbar

git fetch origin pull/1748/head:pr-1748
or exit 1

git switch pr-1748
or exit 1

# Apply our known-good custom files.
cp "$SETUP_DIR/caelestia/patches/Bar.qml" \
    modules/bar/Bar.qml

cp "$SETUP_DIR/caelestia/patches/ActiveWindow.qml" \
    modules/bar/components/ActiveWindow.qml

# ---------------------------------------------------------
# Build user-local Caelestia QML plugin
# ---------------------------------------------------------

rm -rf build

cmake -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$HOME/.local" \
    -DINSTALL_LIBDIR=lib/caelestia-topbar \
    -DINSTALL_QMLDIR=lib/qt6/qml \
    -DINSTALL_QSCONFDIR="$HOME/.config/quickshell/caelestia-topbar"

or exit 1

cmake --build build
or exit 1

cmake --install build
or exit 1

# ---------------------------------------------------------
# Finish
# ---------------------------------------------------------

echo
echo "=============================================="
echo " Installation completed successfully"
echo "=============================================="
echo
echo "Topbar launcher:"
echo "  ~/.local/bin/caelestia-topbar"
echo
echo "Hyprland config:"
echo "  ~/.config/hypr"
echo
echo "Backup:"
echo "  $backup"
echo
echo "Log out and select Hyprland from your login manager."

