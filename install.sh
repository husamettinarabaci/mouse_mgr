#!/bin/bash
set -e

SERVICE_FILE="/etc/systemd/system/mousemgr.service"

# Uninstall if already installed
if [ -f "$SERVICE_FILE" ]; then
    echo "Existing systemd service found. Stopping and removing..."
    sudo systemctl stop mousemgr.service || true
    sudo systemctl disable mousemgr.service || true
    sudo rm -f "$SERVICE_FILE"
    sudo systemctl daemon-reload
    echo "Previous service removed."
fi

echo "[1/4] Checking Rust environment..."
if ! command -v cargo >/dev/null 2>&1; then
    echo "Rust is not installed. Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
fi

echo "[2/4] Installing amixer (alsa-utils)..."
sudo apt-get update && sudo apt-get install -y alsa-utils

echo "[3/4] Building the project..."
cargo build --release

read -p "Do you want to create a systemd service? (y/n): " yn
if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
    sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Mouse horizontal wheel volume control daemon
After=sound.target

[Service]
# Set environment variables for audio control
Environment="XDG_RUNTIME_DIR=/run/user/$(id -u $USER)"
Environment="PULSE_SERVER=unix:/run/user/$(id -u $USER)/pulse/native"
ExecStart=$(pwd)/target/release/mouse_mgr
Restart=always
User=$USER

[Install]
WantedBy=default.target
EOF
    echo "Enabling systemd service..."
    sudo systemctl daemon-reload
    sudo systemctl enable mousemgr.service
    sudo systemctl start mousemgr.service
    echo "Service started. To check status: sudo systemctl status mousemgr.service"
else
    echo "Setup complete. To run manually:"
    echo "sudo ./target/release/mouse_mgr &"
fi
