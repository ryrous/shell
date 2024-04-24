######################################
# Intall DotNet on ARM64
######################################
# install the dependencies
sudo apt install libc6 libgcc1 libgssapi-krb5-2 libicu72 libssl1.1 libstdc++6 zlib1g -y

# Get the .NET install script
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh

# Make it executable
sudo chmod +x dotnet-install.sh

# Install the .NET SDK 8.0 (LTS) for ARM64
./dotnet-install.sh --architecture arm64 --channel LTS

# Install the .NET runtime 8.0 (LTS) for ARM64
# ./dotnet-install.sh --architecture arm64 --channel LTS --runtime dotnet

# Set environment variables system-wide
sudo tee /etc/profile.d/dotnet.sh <<EOF
export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
EOF


######################################
# Install PowerShell on ARM64
######################################
# Install system components
sudo apt update && sudo apt install -y curl gnupg apt-transport-https wget

# Download the Microsoft Repository package
wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb

# Install the Microsoft Repository package
sudo dpkg -i packages-microsoft-prod.deb

# Remove the Microsoft Repository package
rm packages-microsoft-prod.deb

# Update APT (optional)
sudo apt update

# Download the powershell '.tar.gz' archive
curl -L -o /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v7.4.2/powershell-7.4.2-linux-arm64.tar.gz

# Create the target folder where powershell will be placed
sudo mkdir -p /opt/microsoft/powershell/7

# Expand powershell to the target folder
sudo tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7

# Set execute permissions
sudo chmod +x /opt/microsoft/powershell/7/pwsh

# Create the symbolic link that points to pwsh
sudo ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh