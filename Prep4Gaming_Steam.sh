#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo ">>> Updating package lists..."
sudo apt update

# Optional: Upgrade installed packages. Use 'upgrade' for potentially safer upgrades,
# or 'full-upgrade' (equivalent to dist-upgrade) for potentially more disruptive ones.
# Choose one or comment out if you prefer to handle upgrades manually.
echo ">>> Upgrading existing packages (using apt upgrade)..."
sudo apt upgrade -y
# echo ">>> Upgrading existing packages (using apt full-upgrade)..."
# sudo apt full-upgrade -y # Use with caution, may remove packages

echo ">>> Enabling 32-bit architecture (i386)..."
sudo dpkg --add-architecture i386

echo ">>> Updating package lists again after adding i386 architecture..."
sudo apt update

echo ">>> Installing Steam and essential 32-bit libraries for gaming..."

# Combine all installations into a single command for efficiency
# Focus on runtime libraries (:i386) known to be needed by Steam/Proton/Games
# Removed most -dev packages and unnecessary explicit 64-bit packages
# Using generic names where possible, specific names where necessary (like libssl1.1 if targeting older Ubuntu)
# Added steam-installer
sudo apt install -y \
    steam-installer \
    libc6:i386 \
    libncurses5:i386 \
    libncurses6:i386 \
    libstdc++6:i386 \
    libgcc-s1:i386 \
    libsdl2-2.0-0:i386 \
    libsdl2-net-2.0-0:i386 \
    libsdl2-image-2.0-0:i386 \
    libsdl2-mixer-2.0-0:i386 \
    libsdl2-ttf-2.0-0:i386 \
    libopenal1:i386 \
    libfreetype6:i386 \
    libcurl4:i386 \
    libpng16-16:i386 \
    libjpeg-turbo8:i386 \
    libtiff5:i386 \
    libxml2:i386 \
    libssl3:i386 \
    # libssl1.1:i386 \ # Uncomment/Use if targeting Ubuntu 20.04 or earlier where libssl3 isn't default
    zlib1g:i386 \
    libbz2-1.0:i386 \
    libgmp10:i386 \
    libgnutls30:i386 \
    libldap-2.4-2:i386 \ # Or newer versions like libldap-2.5-0 depending on Ubuntu release
    libgpg-error0:i386 \
    libgcrypt20:i386 \
    libdbus-1-3:i386 \
    libudev1:i386 \
    # --- Graphics Libraries (Mesa - Essential for Intel/AMD) ---
    libgl1-mesa-dri:i386 \
    libgl1-mesa-glx:i386 \
    mesa-vulkan-drivers \
    mesa-vulkan-drivers:i386 \
    # --- Vulkan API support ---
    libvulkan1 \
    libvulkan1:i386 \
    vulkan-tools # Useful for diagnostics (vkinfo, vulkaninfo)

# Clean up downloaded package files
sudo apt autoremove -y
sudo apt clean

echo ""
echo ">>> Script finished!"
echo ">>> Steam and essential libraries should now be installed."
echo ">>> IMPORTANT: Ensure you have the correct graphics drivers installed for your GPU:"
echo "    - Intel/AMD: The Mesa drivers installed by this script are usually sufficient."
echo "    - NVIDIA: You will likely need to install the proprietary NVIDIA drivers."
echo "      Use Ubuntu's 'Additional Drivers' tool or follow instructions from NVIDIA/PPA."
echo ">>> You may need to reboot your system."
echo ">>> Run 'steam' from your application menu or terminal to complete setup."

exit 0