#!/bin/bash

# Installer for the CAPT (Custom APT) package manager

# Exit immediately if a command exits with a non-zero status.
set -e

# Define installation directories
INSTALL_DIR="$HOME/.local/bin"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)/src"
CAPT_EXEC="$INSTALL_DIR/capt"

echo "Installing CAPT: The no-sudo package manager..."

# 1. Create the installation directory if it doesn't exist
echo "[1/3] Ensuring installation directory exists..."
mkdir -p "$INSTALL_DIR"

# 2. Copy the capt script to the installation directory
echo "[2/3] Copying capt executable to $INSTALL_DIR..."
cp "$SRC_DIR/capt" "$CAPT_EXEC"

# 3. Make the capt script executable
echo "[3/3] Making capt executable..."
chmod +x "$CAPT_EXEC"

echo -e "\n-------------------------------------------------"
echo "CAPT installation complete!"
echo ""
echo "The capt command will configure the necessary PATH and library variables automatically on its first run."
echo ""
echo "To get started, you MUST reload your shell configuration:"
echo "  source ~/.bashrc"
echo ""
echo "After that, you can run 'capt install <package_name>'
"
echo "-------------------------------------------------"
