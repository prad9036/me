#!/bin/bash

# Installer for CAPT (Custom APT Package Manager)

set -e

# Define installation directory
INSTALL_DIR="$HOME/.local/bin"
CAPT_EXEC="$INSTALL_DIR/capt"
CAPT_URL="https://raw.githubusercontent.com/prad9036/me/refs/heads/main/src/capt"

echo "Installing CAPT: The no-sudo package manager..."

# 1. Ensure installation directory exists
echo "[1/3] Ensuring installation directory exists at $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"

# 2. Download the latest capt script
echo "[2/3] Downloading CAPT executable..."
curl -fsSL "$CAPT_URL" -o "$CAPT_EXEC"

# 3. Make the script executable
echo "[3/3] Making CAPT executable..."
chmod +x "$CAPT_EXEC"

echo -e "\n-------------------------------------------------"
echo "✅ CAPT installation complete!"
echo ""
echo "To get started, reload your shell configuration:"
echo "  source ~/.bashrc"
echo ""
echo "Then you can run:"
echo "  capt install <package_name>"
echo "-------------------------------------------------"
