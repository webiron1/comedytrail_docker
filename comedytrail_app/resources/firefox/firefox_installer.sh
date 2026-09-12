#!/bin/bash
#

set -x

cd /temp

# Uncomment clearing old firefox for reinstall test of this script.
rm -rf /opt/firefox
rm -f /bin/firefox
rm -f /usr/bin/firefox
rm -f /usr/local/bin/firefox

# Install package prerequisites - Done in Dockerfile
# apt update && pt install -y libgtk-3-0 libdbus-glib-1-2 libx11-xcb1 libxt6 libasound2t64 libdbus-glib-1-2

# Clear Old Install If Exists
if [ -d /opt/firefox ]; then
        echo "Clearing old instance of FireFox from /opt/firefox folder..."
        rm -rf /opt/firefox
fi

if [ ! -d /opt ]; then
        echo "Missing /opt folder?"
        mkdir -p /opt
fi

# Install firefox from the tar file in /tmp/firefox.tar
cd /temp

tar xvf firefox.tar -C /opt
chmod +x /opt/firefox/firefox*
chmod +x /opt/firefox/*test*

# Setup user level symlinks to the executable
rm -f /bin/firefox /usr/bin/firefox /usr/local/bin/firefox
ln -s /opt/firefox/firefox /bin/firefox
ln -s /opt/firefox/firefox /usr/local/bin/firefox

# Link to deffault web browser symlinl
rm -f /usr/bin/x-www-browser
ln -s /opt/firefox/firefox /usr/bin/x-www-browser

# Add desktop shortcut
wget https://raw.githubusercontent.com/mozilla/sumo-kb/main/install-firefox-linux/firefox.desktop -P /usr/local/share/applications

#EOF