#!/bin/bash

# Add the official PPA for Nvidia graphics drivers
# The -y flag automatically agrees to add the repository
echo "Adding the graphics-drivers PPA..."
sudo add-apt-repository ppa:graphics-drivers/ppa -y

# Update the package list to include drivers from the PPA
echo "Updating package lists..."
sudo apt update

# Autoinstall the recommended Nvidia driver
# This command checks your hardware and installs the best driver available,
# including those from the PPA you just added.
echo "Autoinstalling the recommended Nvidia driver..."
sudo ubuntu-drivers autoinstall

# Install nvidia-settings (often included, but good to ensure)
# Install Vulkan utilities (useful for checking Vulkan support)
echo "Installing nvidia-settings and vulkan-utils..."
sudo apt install nvidia-settings vulkan-utils -y

echo ""
echo "---------------------------------------------------------------------"
echo " Nvidia driver installation process initiated."
echo " A REBOOT IS REQUIRED for the new drivers to take effect."
echo " After rebooting, you can verify the installation by running:"
echo "   nvidia-smi"
echo " Or check Vulkan support with:"
echo "   vulkaninfo | grep deviceName"
echo "---------------------------------------------------------------------"

# Optional: Prompt for reboot (uncomment if you want the script to offer)
# read -p "Reboot now? (y/N): " response
# if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
# then
#    echo "Rebooting..."
#    sudo reboot
# else
#    echo "Please remember to reboot your system manually."
# fi

exit 0