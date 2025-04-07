
#!/bin/bash
###########################################################
# Install PowerShell Core on Debian/Ubuntu ARM64 via APT
###########################################################

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Variables ---
# Detect Debian/Ubuntu version (adjust if needed for other derivatives)
# Note: This is a basic detection. A more robust script might use /etc/os-release more thoroughly.
DEBIAN_VERSION=$(grep "VERSION_ID=" /etc/os-release | cut -d '"' -f 2)
if [[ -z "$DEBIAN_VERSION" ]]; then
  echo "Could not automatically determine Debian/Ubuntu version."
  # Defaulting to 12, as in the original script. Adjust if necessary.
  DEBIAN_VERSION="12"
  echo "Defaulting to Debian version ${DEBIAN_VERSION}. Verify compatibility."
fi
# Or, explicitly set it:
# DEBIAN_VERSION="12" # For Debian 12 Bookworm
# DEBIAN_VERSION="11" # For Debian 11 Bullseye
# UBUNTU_VERSION="22.04" # For Ubuntu 22.04 Jammy
# UBUNTU_VERSION="24.04" # For Ubuntu 24.04 Noble
# Check Microsoft docs for the correct codename/version for your OS.

# --- Prerequisites ---
echo "Updating package lists and installing prerequisites..."
sudo apt update
sudo apt install -y wget apt-transport-https software-properties-common gnupg curl

# --- Add Microsoft Repository ---
# Note: Using the source list method is often preferred over the .deb package.
echo "Downloading Microsoft GPG key..."
wget -q "https://packages.microsoft.com/config/debian/${DEBIAN_VERSION}/packages-microsoft-prod.deb" -O packages-microsoft-prod.deb

echo "Installing Microsoft repository configuration..."
sudo dpkg -i packages-microsoft-prod.deb

echo "Cleaning up downloaded package..."
rm packages-microsoft-prod.deb

# --- Install PowerShell ---
echo "Updating package lists after adding Microsoft repo..."
sudo apt update

echo "Installing PowerShell..."
sudo apt install -y powershell

echo "PowerShell installation complete. You can now run 'pwsh'."

# Optional: Verify installation
pwsh --version