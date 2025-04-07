#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
# Using variables makes the script easier to read and modify
KEY_URL="https://packages.microsoft.com/keys/microsoft.asc"
KEY_DEST="/etc/apt/keyrings/packages.microsoft.gpg"
REPO_DEST="/etc/apt/sources.list.d/vscode.list"
TEMP_KEY_FILE="packages.microsoft.gpg.tmp" # Use a temporary name

# --- Check for root privileges ---
if [[ $EUID -ne 0 ]]; then
   echo "ERROR: This script must be run as root (use sudo)."
   exit 1
fi

# --- Install prerequisites ---
echo "Updating package list and installing prerequisites (wget, gpg, apt-transport-https)..."
# Use apt-get for scripting stability, combine installations, add -y
apt-get update
apt-get install -y wget gpg apt-transport-https ca-certificates # ca-certificates often needed too

# --- Add Microsoft GPG key ---
echo "Downloading and installing Microsoft GPG key..."
# Download key, dearmor, and save to a temporary file
wget -qO- "$KEY_URL" | gpg --dearmor > "$TEMP_KEY_FILE"
# Use the 'install' command to correctly place the key with proper permissions
install -o root -g root -m 644 "$TEMP_KEY_FILE" "$KEY_DEST"
# Clean up the temporary file
rm -f "$TEMP_KEY_FILE"

# --- Add VS Code repository ---
echo "Detecting architecture and adding VS Code repository..."
# Detect architecture dynamically
ARCH=$(dpkg --print-architecture)
if [ -z "$ARCH" ]; then
    echo "ERROR: Could not determine system architecture using dpkg."
    exit 1
fi
# Create the repository file using the detected architecture
echo "deb [arch=$ARCH signed-by=$KEY_DEST] https://packages.microsoft.com/repos/code stable main" > "$REPO_DEST"

# --- Install VS Code ---
echo "Updating package list and installing Visual Studio Code..."
apt-get update
# Install 'code' package without upgrading the entire system. Use -y for automation.
apt-get install -y code # Use 'code-insiders' for the Insiders build if preferred

echo "Visual Studio Code installation completed successfully."

exit 0