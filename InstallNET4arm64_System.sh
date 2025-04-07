#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
DOTNET_CHANNEL="LTS"
DOTNET_ARCH="arm64"
# Define a system-wide installation directory
INSTALL_DIR="/usr/local/share/dotnet" # Or /opt/dotnet

# --- Dependency Installation ---
echo "Installing dependencies (requires sudo)..."
sudo apt-get update
# Adjust dependencies as needed for your system/version
sudo apt-get install -y libc6 libgcc1 libgssapi-krb5-2 libicu-dev libssl3 libstdc++6 zlib1g wget

# --- Download .NET Install Script ---
echo "Downloading .NET install script..."
# Download to a temporary location accessible by sudo, or handle permissions
wget https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh --quiet
chmod +x /tmp/dotnet-install.sh

# --- Install .NET SDK System-Wide ---
echo "Installing .NET SDK ($DOTNET_CHANNEL) for $DOTNET_ARCH to $INSTALL_DIR (requires sudo)..."
# Run the installer with sudo and specify the install directory
sudo /tmp/dotnet-install.sh --channel "$DOTNET_CHANNEL" --architecture "$DOTNET_ARCH" --install-dir "$INSTALL_DIR"

# --- Set Up Environment Variables System-Wide ---
echo "Setting system-wide environment variables in /etc/profile.d/dotnet.sh..."
# Create the profile script using sudo tee
sudo tee /etc/profile.d/dotnet.sh > /dev/null <<EOF
# .NET Core SDK paths (System-Wide)
export DOTNET_ROOT=$INSTALL_DIR
export PATH=\$PATH:\$DOTNET_ROOT:\$DOTNET_ROOT/tools
EOF
# Make the profile script executable (optional but good practice)
sudo chmod +x /etc/profile.d/dotnet.sh

# --- Clean Up ---
echo "Cleaning up downloaded script..."
sudo rm /tmp/dotnet-install.sh

# --- Final Instructions ---
echo ""
echo ".NET SDK installation complete!"
echo "System-wide environment variables set in /etc/profile.d/dotnet.sh."
echo "Users will need to log out and log back in for changes to take effect."
echo "Verify installation by opening a new terminal and running: dotnet --version"

exit 0