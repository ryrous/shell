#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
# set -u # Optional: Usually good practice, but less critical in this simple script.
# Pipe commands fail if any command in the pipe fails, not just the last one.
set -o pipefail

echo "Starting Brave Browser installation script..."

# --- Prerequisites ---
echo "Updating package list and installing prerequisites (curl, ca-certificates, apt-transport-https)..."
# Ensure apt cache is up-to-date first
sudo apt update
# Install necessary packages. -y avoids interactive prompts.
# ca-certificates is needed for HTTPS access.
# apt-transport-https ensures apt can handle https repos (often included by default now, but good to be sure).
sudo apt install -y curl ca-certificates apt-transport-https

# --- Add Brave GPG Key ---
echo "Downloading and adding Brave Browser GPG key..."
# Create the directory for apt keyrings if it doesn't exist
# Using /etc/apt/keyrings is the modern standard location for manually added keys
sudo install -m 0755 -d /etc/apt/keyrings
# Download the key using curl and save it to the created directory
KEYRING_PATH="/etc/apt/keyrings/brave-browser-archive-keyring.gpg"
sudo curl -fsSLo "$KEYRING_PATH" https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
# Ensure the key file has appropriate permissions (readable by all, writable only by root)
sudo chmod 644 "$KEYRING_PATH"

# --- Add Brave APT Repository ---
echo "Adding the Brave Browser APT repository..."
# Determine system architecture (e.g., amd64, arm64)
ARCH=$(dpkg --print-architecture)
# Create the sources list file, referencing the specific GPG key and architecture
SOURCES_LIST_PATH="/etc/apt/sources.list.d/brave-browser-release.list"
echo "deb [signed-by=$KEYRING_PATH arch=$ARCH] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee "$SOURCES_LIST_PATH" > /dev/null

# --- Install Brave Browser ---
echo "Updating package list again..."
sudo apt update

echo "Installing Brave Browser..."
# Install the package, automatically confirming with -y
sudo apt install -y brave-browser

echo "Brave Browser installation completed successfully!"

exit 0