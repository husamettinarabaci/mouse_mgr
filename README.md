# MouseMgr - Logitech MX Series Horizontal Wheel Volume Control

MouseMgr is a Rust-based Linux daemon that lets you control your system volume using the horizontal scroll wheel (side scroll) of your Logitech MX series mouse (or any mouse with a horizontal wheel). It listens for horizontal wheel events and adjusts the system volume up or down accordingly.

## Features
- Works with Logitech MX series and other mice supporting horizontal scroll (REL_HWHEEL/REL_HWHEEL_HI_RES)
- Runs as a background daemon (systemd service supported)
- Uses `amixer` for volume control (ALSA compatible)
- Easy installation script with auto-reinstall and systemd integration
- MIT Licensed

## Installation

1. **Clone the repository:**
   ```sh
   git clone husamettinarabaci/mouse_mgr
   cd mouse_mgr
   ```
2. **Run the installer:**
   ```sh
   chmod +x install.sh
   ./install.sh
   ```
   - The script will install dependencies, build the project, and optionally set up a systemd service.
   - If you choose systemd, the service will start automatically on boot.

## Usage
- If you enabled the systemd service, the daemon will run in the background and respond to horizontal wheel events.
- To check logs and debug:
  ```sh
  journalctl -u mousemgr.service -f
  ```
- To run manually (without systemd):
  ```sh
  sudo ./target/release/mouse_mgr &
  ```

## Requirements
- Linux (tested on Ubuntu/Pop!_OS)
- Rust toolchain
- `amixer` (ALSA utils)
- A mouse with a horizontal scroll wheel (Logitech MX series recommended)

## License
MIT License. See [LICENSE](LICENSE).

---

**Author:** Husamettin ARABACI
