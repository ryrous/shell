# Edit proxychains.conf:
sudo mousepad /etc/proxychains4.conf
# Uncomment "strict_chain" and "proxy_dns"
# Uncomment the last line of the file to look like this:
# socks5 127.0.0.1 9050
# Save and close the file

# Restart proxychains:
sudo systemctl restart proxychains4

# Start tor:
sudo systemctl start tor

# Start firefox:
proxychains firefox