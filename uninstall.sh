#!/bin/bash
# uninstall.sh - Uninstall script for mouse_mgr project

set -e

SERVICE_FILE="/etc/systemd/system/mousemgr.service"

# Stop and remove systemd service if it exists
if [ -f "$SERVICE_FILE" ]; then
    echo "[uninstall] Stopping and disabling systemd service..."
    sudo systemctl stop mousemgr.service || true
    sudo systemctl disable mousemgr.service || true
    sudo rm -f "$SERVICE_FILE"
    sudo systemctl daemon-reload
    echo "[uninstall] Systemd service removed."
fi

# Optionally remove alsa-utils (amixer)
read -p "Do you want to remove alsa-utils (amixer)? (y/n): " yn
if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
    echo "[uninstall] Removing alsa-utils..."
    sudo apt-get remove -y alsa-utils
fi

# Remove build artifacts
echo "[uninstall] Removing target/ directory..."
rm -rf target/

echo "[uninstall] mouse_mgr uninstallation complete."
