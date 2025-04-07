#!/bin/bash

# --- Configuration ---
# Check the official Proton VPN Linux installation guide for the latest URL:
# https://protonvpn.com/support/linux-debian-install/
REPO_DEB_URL="https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3-3_all.deb"
REPO_DEB_FILENAME=$(basename "$REPO_DEB_URL")
# Choose packages to install: "cli" "gui" or "both"
INSTALL_TYPE="gui" # Options: "cli", "gui", "both"
# Install GNOME tray icon support? (Only relevant if using GNOME DE)
INSTALL_GNOME_TRAY_SUPPORT=true # Options: true, false
# --- End Configuration ---

# Exit immediately if a command exits with a non-zero status.
set -e

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "ERROR: This script must be run as root (use 'sudo bash $0')"
   exit 1
fi

echo ">>> Starting Proton VPN Installation Script for Debian <<<"

# Check for required commands
if ! command -v wget &> /dev/null || ! command -v dpkg &> /dev/null || ! command -v apt &> /dev/null; then
    echo "ERROR: Required commands (wget, dpkg, apt) not found. Please install them."
    exit 1
fi

# --- Download Repository Setup ---
echo "[1/5] Downloading Proton VPN repository configuration..."
# Check if the file already exists, remove if it does to ensure fresh download
rm -f "./$REPO_DEB_FILENAME"
if wget -q --show-progress -O "./$REPO_DEB_FILENAME" "$REPO_DEB_URL"; then
    echo "Download successful."
else
    echo "ERROR: Failed to download repository package from $REPO_DEB_URL"
    echo "Please check the URL and your internet connection."
    exit 1
fi

# --- Install Repository ---
echo "[2/5] Installing Proton VPN repository..."
if dpkg -i "./$REPO_DEB_FILENAME"; then
    echo "Repository installed successfully."
else
    echo "ERROR: Failed to install repository package with dpkg."
    # Attempt to fix broken dependencies if dpkg failed
    echo "Attempting to fix potential dependency issues..."
    apt --fix-broken install -y || { echo "ERROR: 'apt --fix-broken install' failed."; exit 1; }
    # Retry installing the package after fixing dependencies
    echo "Retrying repository package installation..."
    dpkg -i "./$REPO_DEB_FILENAME" || { echo "ERROR: Failed to install repository package even after fixing dependencies."; exit 1; }
fi

# --- Update Package Lists ---
echo "[3/5] Updating package lists..."
apt update

# --- Install Proton VPN Packages ---
packages_to_install=()
case "$INSTALL_TYPE" in
    cli)
        packages_to_install+=("proton-vpn-cli")
        echo "[4/5] Installing Proton VPN CLI..."
        ;;
    gui)
        # Installs both the GUI app and the necessary backend/CLI
        packages_to_install+=("proton-vpn-gui")
        echo "[4/5] Installing Proton VPN GUI (includes CLI)..."
        ;;
    both)
        # Explicitly install both (though 'proton-vpn-gui' should pull 'proton-vpn-cli')
        packages_to_install+=("proton-vpn-cli" "proton-vpn-gui")
        echo "[4/5] Installing Proton VPN GUI and CLI..."
        ;;
    *)
        echo "ERROR: Invalid INSTALL_TYPE configured in script. Use 'cli', 'gui', or 'both'."
        exit 1
        ;;
esac

if apt install -y "${packages_to_install[@]}"; then
    echo "Proton VPN package(s) installed successfully."
else
    echo "ERROR: Failed to install Proton VPN package(s): ${packages_to_install[*]}"
    exit 1
fi

# --- Install Optional GNOME Tray Support ---
# Check if running GNOME and if user wants tray support
if [[ "$INSTALL_GNOME_TRAY_SUPPORT" = true ]]; then
    # Simple check for GNOME session (may not be 100% reliable in all cases)
    if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* || "$GNOME_DESKTOP_SESSION_ID" ]]; then
        echo "[5/5] Installing GNOME Ayatana AppIndicator support (for tray icon)..."
        # Use apt-get check to see if packages are needed, avoids reinstalling if already present
        needs_install=false
        for pkg in libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator; do
            if ! dpkg -s "$pkg" &> /dev/null; then
                needs_install=true
                break
            fi
        done

        if $needs_install; then
            if apt install -y libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator; then
                echo "GNOME tray icon support installed. You may need to log out and back in or restart GNOME Shell (Alt+F2, r, Enter) for the extension to be enabled."
            else
                echo "WARNING: Failed to install GNOME tray icon support packages. Tray icon may not work."
                # Continue script execution as this is optional
            fi
        else
             echo "[5/5] GNOME Ayatana AppIndicator support already installed."
        fi
    else
        echo "[5/5] Skipping GNOME tray icon support installation (not detected as running GNOME)."
    fi
else
    echo "[5/5] Skipping optional GNOME tray icon support installation (disabled in script)."
fi


# --- Cleanup ---
echo "Cleaning up downloaded repository file..."
rm -f "./$REPO_DEB_FILENAME"

# --- Final Message ---
echo ""
echo ">>> Proton VPN Installation Script Finished <<<"
echo ""
if [[ "$INSTALL_TYPE" == "gui" || "$INSTALL_TYPE" == "both" ]]; then
 echo "You should now be able to launch the Proton VPN application from your application menu."
 echo "If you installed tray support, you might need to log out and back in for it to appear."
elif [[ "$INSTALL_TYPE" == "cli" ]]; then
 echo "You can now use the Proton VPN CLI. Try running 'protonvpn-cli --help'."
fi
echo "It's recommended to reboot your system or at least log out/in to ensure all changes take effect."

exit 0