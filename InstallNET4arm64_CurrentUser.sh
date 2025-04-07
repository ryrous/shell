#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# --- Configuration ---
# Specify the .NET version/channel. LTS is generally recommended.
# Other examples: "8.0", "STS" (Standard Term Support), "preview"
DOTNET_CHANNEL="LTS"
# Specify architecture (arm64, x64, etc.). Should auto-detect but explicit is safer.
DOTNET_ARCH="arm64"

# --- Dependency Installation ---
# Note: Dependency names might vary. Check official MS docs for your distro/version.
# Example for Debian/Ubuntu based systems (adapt as needed):
echo "Installing dependencies (requires sudo)..."
# Update package list first
sudo apt-get update
# Install common dependencies - adjust based on distro & .NET version requirements
# libicu usually comes from 'icu-devtools' or similar, check package manager
# libssl dependency is often libssl3 now
sudo apt-get install -y libc6 libgcc1 libgssapi-krb5-2 libicu-dev libssl3 libstdc++6 zlib1g wget

# --- Download .NET Install Script ---
echo "Downloading .NET install script..."
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh --quiet
chmod +x dotnet-install.sh

# --- Install .NET SDK ---
# Installs to $HOME/.dotnet by default
echo "Installing .NET SDK ($DOTNET_CHANNEL) for $DOTNET_ARCH..."
./dotnet-install.sh --channel "$DOTNET_CHANNEL" --architecture "$DOTNET_ARCH" --install-dir "$HOME/.dotnet"

# --- Set Up Environment Variables for Current User ---
# Detect shell and update the appropriate profile file
PROFILE_FILE=""
if [ -n "$BASH_VERSION" ]; then
    PROFILE_FILE="$HOME/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
    PROFILE_FILE="$HOME/.zshrc"
else
    # Fallback for other shells, may need adjustment
    PROFILE_FILE="$HOME/.profile"
fi

echo "Adding .NET environment variables to $PROFILE_FILE..."

# Ensure the export lines are added only once
grep -q 'export DOTNET_ROOT=' "$PROFILE_FILE" || echo '' >> "$PROFILE_FILE" # Add newline if needed
grep -q 'export DOTNET_ROOT=' "$PROFILE_FILE" || echo '# .NET Core SDK paths' >> "$PROFILE_FILE"
grep -q 'export DOTNET_ROOT=' "$PROFILE_FILE" || echo 'export DOTNET_ROOT=$HOME/.dotnet' >> "$PROFILE_FILE"
grep -q '$DOTNET_ROOT/tools' "$PROFILE_FILE" || echo 'export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools' >> "$PROFILE_FILE"

# --- Clean Up ---
echo "Cleaning up downloaded script..."
rm dotnet-install.sh

# --- Final Instructions ---
echo ""
echo ".NET SDK installation complete!"
echo "Environment variables added to $PROFILE_FILE."
echo "Please restart your terminal or run 'source $PROFILE_FILE' for changes to take effect."
echo "Verify installation by running: dotnet --version"

exit 0