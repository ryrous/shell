# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)" 
   exit 1
fi

# Download the repository configuration and keys required to install the Proton VPN app. Enter:
wget https://repo2.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3-3_all.deb

# Install the Proton VPN repository containing the new app. Enter:
dpkg -i ./protonvpn-stable-release_1.0.3-3_all.deb && apt update

# If you don’t have Proton VPN installed, run:
apt install -y proton-vpn-gnome-desktop

# To check for updates and ensure that you’re running the latest version of the app, enter:
apt update && apt upgrade -y

# By default, the GNOME desktop doesn’t support tray icons. To enable this functionality on Debian-based distributions:
apt install -y libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator

# Restart the Proton VPN app to apply the changes 