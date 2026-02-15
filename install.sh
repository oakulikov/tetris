#!/bin/bash

set -e

# Wrap everything in a function so `curl | bash` reads the entire
# script before executing (avoids pipe-buffering parse errors).
install_tetris() {

# Configuration
REPO="oakulikov/tetris"
INSTALL_DIR="/usr/local/bin"
BIN_NAME="tetris"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

echo -e "${CYAN}"
echo "  ████████╗███████╗████████╗██████╗ ██╗███████╗"
echo "  ╚══██╔══╝██╔════╝╚══██╔══╝██╔══██╗██║██╔════╝"
echo "     ██║   █████╗     ██║   ██████╔╝██║███████╗"
echo "     ██║   ██╔══╝     ██║   ██╔══██╗██║╚════██║"
echo "     ██║   ███████╗   ██║   ██║  ██║██║███████║"
echo "     ╚═╝   ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚══════╝"
echo -e "${NC}"
echo "  Classic terminal Tetris written in CLI Toolkit"
echo ""

# 1. Check platform
OS="$(uname -s)"
ARCH="$(uname -m)"

case "${OS}" in
    Linux*)     OS='linux';;
    Darwin*)    OS='darwin';;
    FreeBSD*)   OS='freebsd';;
    MINGW*|MSYS*|CYGWIN*)
        error "Native Windows is not supported.\nInstall WSL and run from Ubuntu terminal:\n  wsl --install\nThen re-run this script inside WSL.";;
    *)
        error "Unsupported operating system: ${OS}. Tetris requires a Unix terminal.";;
esac

case "${ARCH}" in
    x86_64)        ARCH='amd64';;
    arm64|aarch64) ARCH='arm64';;
    *)             error "Unsupported architecture: ${ARCH}";;
esac

log "Detected system: $OS/$ARCH"

# 2. Find latest release
log "Checking latest release..."
LATEST_TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_TAG" ]; then
    error "Could not find latest release. Check your internet connection."
fi

log "Latest version: $LATEST_TAG"

# 3. Download binary
ASSET_NAME="tetris-${OS}-${ARCH}"
URL="https://github.com/$REPO/releases/download/$LATEST_TAG/$ASSET_NAME"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

log "Downloading $ASSET_NAME..."
if ! curl -L -f -o "$TMP_DIR/$BIN_NAME" "$URL" 2>/dev/null; then
    error "Failed to download from $URL\nAsset not found for $OS/$ARCH."
fi

chmod +x "$TMP_DIR/$BIN_NAME"
log "Download complete."

# 4. Choose install directory
if [ -e /dev/tty ]; then
    echo ""
    printf "Install to ${BLUE}${INSTALL_DIR}${NC}? [Y/n] "
    read -r answer < /dev/tty
    case "$answer" in
        [nN]*)
            printf "Enter install directory: "
            read -r custom_dir < /dev/tty
            if [ -z "$custom_dir" ]; then
                error "No directory specified"
            fi
            INSTALL_DIR="${custom_dir/#\~/$HOME}"
            ;;
    esac
else
    log "Non-interactive mode, installing to $INSTALL_DIR"
fi

# 5. Install
mkdir -p "$INSTALL_DIR" 2>/dev/null || sudo mkdir -p "$INSTALL_DIR"

log "Installing to $INSTALL_DIR..."
if [ -w "$INSTALL_DIR" ]; then
    mv "$TMP_DIR/$BIN_NAME" "$INSTALL_DIR/$BIN_NAME"
else
    log "Requires sudo for $INSTALL_DIR"
    sudo mv "$TMP_DIR/$BIN_NAME" "$INSTALL_DIR/$BIN_NAME"
fi

echo ""
if [ -f "$INSTALL_DIR/$BIN_NAME" ]; then
    success "Installed: $INSTALL_DIR/$BIN_NAME"
    echo ""
    echo -e "  Run ${CYAN}tetris${NC} to play!"
    echo ""
else
    error "$INSTALL_DIR/$BIN_NAME not found after install"
fi

}

# Run the installer
install_tetris
