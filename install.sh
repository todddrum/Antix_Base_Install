#!/bin/bash
# =============================================================================
# AntiX Base Install — Lightweight Desktop + ESP32 Dev + Claude Code
# Run as root: sudo bash install.sh
#
# Tested on AntiX Core 64-bit (sysvinit, not systemd)
# Fixes applied after first real-world install:
#   - Node.js via apt instead of NodeSource (NodeSource fails on AntiX)
#   - Openbox config written via temp files then chowned (heredoc+sudo fix)
#   - LightDM/NetworkManager enabled via update-rc.d (sysvinit, not systemctl)
#   - picom removed from autostart (causes lag on older GPUs)
# =============================================================================

set -e

USERNAME="todd"
HOME_DIR="/home/$USERNAME"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log()  { echo -e "${GREEN}[INSTALL]${NC} $1"; }
warn() { echo -e "${YELLOW}[ NOTE ]${NC} $1"; }
err()  { echo -e "${RED}[ ERROR ]${NC} $1"; exit 1; }

[ "$(id -u)" -eq 0 ] || err "Run this script as root: sudo bash install.sh"

# -----------------------------------------------------------------------------
# 1. System update
# -----------------------------------------------------------------------------
log "Updating system packages..."
apt update && apt upgrade -y

# -----------------------------------------------------------------------------
# 2. Xorg (minimal)
# -----------------------------------------------------------------------------
log "Installing Xorg..."
apt install -y \
    xserver-xorg \
    x11-utils \
    x11-xserver-utils \
    xinit

# -----------------------------------------------------------------------------
# 3. Openbox desktop stack
# -----------------------------------------------------------------------------
log "Installing Openbox desktop stack..."
apt install -y \
    openbox obconf \
    tint2 \
    pcmanfm gvfs \
    lxterminal \
    geany \
    ghostwriter \
    rofi \
    dunst \
    xarchiver \
    gpicview \
    zathura zathura-pdf-poppler \
    mpv \
    scrot \
    fonts-liberation fonts-dejavu-core \
    htop \
    nano vim \
    git curl wget unzip \
    xdg-utils

# -----------------------------------------------------------------------------
# 4. LightDM display manager
# -----------------------------------------------------------------------------
log "Installing LightDM..."
apt install -y lightdm lightdm-gtk-greeter

# -----------------------------------------------------------------------------
# 5. Firefox ESR (needed for Claude Code OAuth login)
# -----------------------------------------------------------------------------
log "Installing Firefox ESR..."
apt install -y firefox-esr

# -----------------------------------------------------------------------------
# 6. Audio
# -----------------------------------------------------------------------------
log "Installing audio (PulseAudio)..."
apt install -y pulseaudio pulseaudio-utils pavucontrol

# -----------------------------------------------------------------------------
# 7. Network — ethernet + WiFi
# AntiX uses sysvinit — use update-rc.d, not systemctl
# -----------------------------------------------------------------------------
log "Installing NetworkManager with WiFi support..."
apt install -y \
    network-manager \
    network-manager-gnome \
    wpasupplicant \
    wireless-tools \
    iw

update-rc.d network-manager defaults 2>/dev/null || true

# -----------------------------------------------------------------------------
# 8. ESP32 / MicroPython development tools
# -----------------------------------------------------------------------------
log "Installing ESP32 dev tools..."
apt install -y \
    python3 python3-pip python3-venv \
    thonny \
    minicom

log "Creating esptool virtualenv for $USERNAME..."
sudo -u "$USERNAME" python3 -m venv "$HOME_DIR/esptool_env"
sudo -u "$USERNAME" "$HOME_DIR/esptool_env/bin/pip" install --upgrade pip esptool mpremote

log "Adding $USERNAME to dialout group (serial port access)..."
usermod -aG dialout "$USERNAME"

# -----------------------------------------------------------------------------
# 9. Node.js + npm via apt (NodeSource script fails on AntiX)
# -----------------------------------------------------------------------------
log "Installing Node.js and npm via apt..."
apt install -y nodejs npm

node --version
npm --version

# -----------------------------------------------------------------------------
# 10. Claude Code
# -----------------------------------------------------------------------------
log "Installing Claude Code CLI..."
npm install -g @anthropic-ai/claude-code

claude --version || warn "claude --version failed — PATH may need reload, this is normal"

# -----------------------------------------------------------------------------
# 11. Openbox configuration
#     Write files as root then chown — avoids heredoc+sudo-u issues
# -----------------------------------------------------------------------------
log "Configuring Openbox for $USERNAME..."

mkdir -p "$HOME_DIR/.config/openbox"

# -- Autostart (picom omitted — causes lag on older GPUs) --
cat > "$HOME_DIR/.config/openbox/autostart" << 'AUTOSTART'
# Background color
xsetroot -solid "#1e2127" &

# Taskbar / panel
tint2 &

# Network Manager system tray applet
nm-applet &

# Notification daemon
dunst &
AUTOSTART

# -- Right-click desktop menu --
cat > "$HOME_DIR/.config/openbox/menu.xml" << 'MENU'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_menu xmlns="http://openbox.org/3.4/menu">
  <menu id="root-menu" label="Desktop Menu">
    <item label="Terminal">
      <action name="Execute"><command>lxterminal</command></action>
    </item>
    <item label="File Manager">
      <action name="Execute"><command>pcmanfm</command></action>
    </item>
    <separator/>
    <item label="Text Editor (Geany)">
      <action name="Execute"><command>geany</command></action>
    </item>
    <item label="Markdown Editor (Ghostwriter)">
      <action name="Execute"><command>ghostwriter</command></action>
    </item>
    <item label="Firefox">
      <action name="Execute"><command>firefox-esr</command></action>
    </item>
    <separator/>
    <item label="Thonny — MicroPython / ESP32">
      <action name="Execute"><command>thonny</command></action>
    </item>
    <separator/>
    <item label="App Launcher (rofi)">
      <action name="Execute"><command>rofi -show drun</command></action>
    </item>
    <item label="System Monitor (htop)">
      <action name="Execute"><command>lxterminal -e htop</command></action>
    </item>
    <separator/>
    <item label="Logout">
      <action name="Exit"/>
    </item>
  </menu>
</openbox_menu>
MENU

# -- rc.xml: keyboard shortcuts and window behavior --
cat > "$HOME_DIR/.config/openbox/rc.xml" << 'RC'
<?xml version="1.0" encoding="UTF-8"?>
<openbox_config xmlns="http://openbox.org/3.4/rc">
  <keyboard>
    <keybind key="W-Return">
      <action name="Execute"><command>lxterminal</command></action>
    </keybind>
    <keybind key="W-e">
      <action name="Execute"><command>pcmanfm</command></action>
    </keybind>
    <keybind key="W-r">
      <action name="Execute"><command>rofi -show drun</command></action>
    </keybind>
    <keybind key="W-b">
      <action name="Execute"><command>firefox-esr</command></action>
    </keybind>
    <keybind key="Print">
      <action name="Execute"><command>scrot ~/Pictures/screenshot_%Y%m%d_%H%M%S.png</command></action>
    </keybind>
    <keybind key="A-F4">
      <action name="Close"/>
    </keybind>
    <keybind key="A-Tab">
      <action name="NextWindow"/>
    </keybind>
  </keyboard>
  <mouse>
    <context name="Desktop">
      <mousebind button="Right" action="Press">
        <action name="ShowMenu"><menu>root-menu</menu></action>
      </mousebind>
    </context>
  </mouse>
  <theme>
    <name>Clearlooks</name>
    <titleLayout>NLIMC</titleLayout>
  </theme>
  <desktops>
    <number>2</number>
  </desktops>
  <applications/>
</openbox_config>
RC

chown -R "$USERNAME:$USERNAME" "$HOME_DIR/.config"
chmod +x "$HOME_DIR/.config/openbox/autostart"

# -----------------------------------------------------------------------------
# 12. LightDM — Openbox session entry + enable via sysvinit
# -----------------------------------------------------------------------------
if [ ! -f /usr/share/xsessions/openbox.desktop ]; then
    cat > /usr/share/xsessions/openbox.desktop << 'SESSION'
[Desktop Entry]
Name=Openbox
Comment=Log in using Openbox
Exec=/usr/bin/openbox-session
TryExec=/usr/bin/openbox-session
Type=Application
DesktopNames=Openbox
SESSION
fi

update-rc.d lightdm defaults

# -----------------------------------------------------------------------------
# 13. Create Pictures folder for screenshots
# -----------------------------------------------------------------------------
sudo -u "$USERNAME" mkdir -p "$HOME_DIR/Pictures"

# -----------------------------------------------------------------------------
# 14. SSHFS — mount main machine's ~/Projects over the network
#     Main machine hostname: mx.local  (avahi mDNS)
#     Usage: mount-projects / umount-projects / projects-status
# -----------------------------------------------------------------------------
log "Installing SSHFS and Avahi (mDNS)..."
apt install -y sshfs avahi-daemon

sudo -u "$USERNAME" mkdir -p "$HOME_DIR/Projects"

cat >> "$HOME_DIR/.bashrc" << 'ALIASES'

# --- Remote Projects mount (main machine via SSHFS) ---
alias mount-projects='sshfs todd@mx.local:/home/todd/Projects ~/Projects && echo "Projects mounted."'
alias umount-projects='fusermount -u ~/Projects && echo "Projects unmounted."'
alias projects-status='mountpoint -q ~/Projects && echo "Projects: MOUNTED" || echo "Projects: not mounted"'
ALIASES

chown "$USERNAME:$USERNAME" "$HOME_DIR/.bashrc"

# Generate SSH keypair for todd (if not already present)
if [ ! -f "$HOME_DIR/.ssh/id_ed25519" ]; then
    log "Generating SSH keypair for $USERNAME..."
    sudo -u "$USERNAME" ssh-keygen -t ed25519 -f "$HOME_DIR/.ssh/id_ed25519" -N "" -C "todd@antix-laptop"
fi

log "SSHFS configured. See NEXT STEPS for SSH key setup."

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo ""
echo -e "${GREEN}============================================================${NC}"
echo -e "${GREEN}  Installation complete!${NC}"
echo -e "${GREEN}============================================================${NC}"
echo ""
warn "NEXT STEPS (in order):"
echo "  1.  Reboot:           sudo reboot"
echo "  2.  Log in as 'todd' at the LightDM screen"
echo "  3.  Select 'Openbox' session if prompted"
echo "  4.  Open Firefox (right-click desktop → Firefox)"
echo "  5.  Log into claude.ai in Firefox to authorize Claude Code"
echo "  6.  Open Terminal (Super+Enter) and run:  claude"
echo "      Follow the OAuth prompts to complete login"
echo ""
echo "  --- SSH key setup (one-time, for Projects mount) ---"
echo "  7.  On THIS laptop, copy your public key:"
echo "        cat ~/.ssh/id_ed25519.pub"
echo "  8.  On the MAIN machine (mx), authorize it:"
echo "        ssh-copy-id todd@mx.local"
echo "  9.  Test: ssh todd@mx.local"
echo "  10. Mount: mount-projects"
echo "  11. Verify: projects-status && ls ~/Projects/"
echo ""
echo "  --- ESP32 ---"
echo "  12. Plug in ESP32, then:"
echo "        ls /dev/ttyUSB*"
echo "        source ~/esptool_env/bin/activate"
echo "        esptool chip_id"
echo ""
warn "Keyboard shortcuts:"
echo "  Super+Enter  → Terminal"
echo "  Super+R      → App launcher (rofi)"
echo "  Super+E      → File manager"
echo "  Super+B      → Firefox"
echo "  PrtScr       → Screenshot (saved to ~/Pictures)"
echo "  Right-click desktop → Menu"
echo ""
