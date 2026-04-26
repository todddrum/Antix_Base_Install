# AntiX Base Install — Light Desktop Project

## Goal
Build a lightweight but fully functional desktop OS on top of AntiX Core (64-bit),
for an old laptop on a home ethernet + WiFi network. Includes Claude Code CLI
with OAuth login so the project can continue from the new machine.

---

## Hardware Profile (confirmed)

| Spec         | Value           |
|--------------|-----------------|
| RAM          | 3.4 GB          |
| Network      | Ethernet + WiFi |
| Architecture | 64-bit          |
| Username     | todd            |
| Login        | LightDM         |
| Anthropic    | Pro account     |

---

## Package Decisions (final)

| Role              | Package           | Notes                                      |
|-------------------|-------------------|--------------------------------------------|
| Window Manager    | openbox           | Right-click menus, keyboard shortcuts      |
| Panel             | tint2             | Taskbar, systray, clock                    |
| File Manager      | pcmanfm + gvfs    | Fast, supports USB/network mounts          |
| Terminal          | lxterminal        | Tabbed, lightweight                        |
| Text Editor       | geany             | Lightweight IDE for Python/Bash            |
| Markdown Editor   | ghostwriter       | Live preview, Qt-based — NOT Electron      |
| Web Browser       | firefox-esr       | Needed for Claude Code OAuth login         |
| App Launcher      | rofi              | Super+R keyboard launcher                  |
| PDF Viewer        | zathura           | Keyboard-driven, very light                |
| Image Viewer      | gpicview          | Tiny and fast                              |
| Media Player      | mpv               | Best performance/quality for video         |
| Notifications     | dunst             | Lightweight notification daemon            |
| Audio mixer       | pavucontrol       | PulseAudio GUI                             |
| Screenshot        | scrot             | PrtScr → ~/Pictures/                       |
| Compositor        | picom             | 3.4GB RAM = no reason to skip it           |
| Archiver          | xarchiver         | Lightweight GUI archiver                   |
| Fonts             | fonts-liberation  | MS-metric compatible                       |
| System monitor    | htop              | Terminal resource monitor                  |
| Network           | NetworkManager    | Handles ethernet + WiFi + nm-applet tray   |
| WiFi              | wpasupplicant     | WPA/WPA2 backend for NetworkManager        |
| Display manager   | LightDM           | Graphical login screen                     |

### ESP32 / MicroPython Stack

| Tool         | Install method       | Purpose                            |
|--------------|----------------------|------------------------------------|
| python3      | apt                  | Foundation                         |
| python3-venv | apt                  | Virtualenv support                 |
| esptool      | pip (~/esptool_env)  | Flash MicroPython firmware         |
| mpremote     | pip (~/esptool_env)  | File transfer + REPL access        |
| thonny       | apt                  | MicroPython IDE with built-in REPL |
| minicom      | apt                  | Serial terminal fallback           |
| dialout group| usermod              | Serial port access without sudo    |

### Claude Code
- Installed via: `npm install -g @anthropic-ai/claude-code`
- Requires: Node.js LTS (installed via NodeSource)
- Auth: First run of `claude` opens Firefox for OAuth → log in with Pro account

---

## Keyboard Shortcuts (configured in rc.xml)

| Shortcut            | Action              |
|---------------------|---------------------|
| Super+Enter         | Terminal            |
| Super+R             | App launcher (rofi) |
| Super+E             | File manager        |
| Super+B             | Firefox             |
| PrtScr              | Screenshot          |
| Alt+F4              | Close window        |
| Alt+Tab             | Switch windows      |
| Right-click desktop | Desktop menu        |

---

## Install Checklist

### Pre-install
- [ ] Boot AntiX Core ISO and install base system
- [ ] Connect ethernet cable
- [ ] Complete AntiX base install (set username: todd)
- [ ] Boot into AntiX Core terminal, confirm internet: `ping -c 3 debian.org`
- [ ] Copy or download install.sh to the machine

### Run Script
- [ ] `sudo bash install.sh`
- [ ] Watch for any apt errors during install
- [ ] Confirm Node.js version printed (should be 20+ LTS)
- [ ] Confirm Claude Code version printed

### First Boot
- [ ] Reboot into LightDM
- [ ] Log in as todd, select Openbox session
- [ ] Verify desktop loads (tint2 panel visible, right-click menu works)
- [ ] Verify WiFi appears in nm-applet (system tray)
- [ ] Open Firefox — confirm it launches

### Claude Code Auth
- [ ] Open Firefox, confirm claude.ai Pro account login
- [ ] Open lxterminal, run: `claude`
- [ ] Complete OAuth browser flow
- [ ] Verify a test prompt works

### ESP32 Verification
- [ ] Plug in ESP32 via USB
- [ ] Check: `ls /dev/ttyUSB*`
- [ ] Activate venv: `source ~/esptool_env/bin/activate`
- [ ] Test: `esptool.py chip_id`
- [ ] Launch Thonny and connect to board via MicroPython REPL

### SSHFS — Remote Projects Mount
- [ ] On AntiX laptop: `cat ~/.ssh/id_ed25519.pub` (generated by install script)
- [ ] On main machine (mx): `echo 'PASTE_KEY' >> ~/.ssh/authorized_keys`
      or simpler: `ssh-copy-id todd@mx.local` from the AntiX laptop
- [ ] Test SSH: `ssh todd@mx.local`
- [ ] Mount: `mount-projects`
- [ ] Verify: `projects-status` and `ls ~/Projects/`

**Aliases available after install:**

| Alias             | Action                              |
|-------------------|-------------------------------------|
| `mount-projects`  | Mount main machine ~/Projects       |
| `umount-projects` | Unmount cleanly                     |
| `projects-status` | Check if currently mounted          |

**Note:** Main machine (mx) needs `openssh-server` and `avahi-daemon` running.
Run on mx if not already: `sudo apt install openssh-server avahi-daemon`

### Project Continuity
- [ ] Run `mount-projects` to access files from main machine
- [ ] Or clone this repo directly: `git clone git@github.com:todddrum/Antix_Base_Install.git`
- [ ] Run `claude` in the project directory and continue work

---

## Status

| Phase              | Status         |
|--------------------|----------------|
| Hardware profiling | ✅ Complete     |
| Package selection  | ✅ Complete     |
| Script written     | ✅ Complete     |
| AntiX base install | ⏳ Pending      |
| Script test run    | ⏳ Pending      |
| Claude Code auth   | ⏳ Pending      |
| ESP32 test         | ⏳ Pending      |

---

## Files

| File          | Purpose                           |
|---------------|-----------------------------------|
| install.sh    | Main install script (run as root) |
| PROGRESS.md   | This file — checklist and notes   |
