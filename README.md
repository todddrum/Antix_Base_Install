# AntiX Base Install

Automated setup script to turn a fresh **AntiX Core** install into a lightweight
Openbox desktop with ESP32/MicroPython dev tools and Claude Code CLI.

---

## What gets installed

- **Openbox** desktop + tint2 panel + LightDM login screen
- **Firefox ESR**, Ghostwriter (markdown), Geany, pcmanfm, rofi, mpv, zathura
- **NetworkManager** — ethernet + WiFi
- **ESP32 stack** — Thonny IDE, esptool venv, mpremote, minicom, dialout group
- **Node.js LTS** + **Claude Code CLI** (Anthropic AI assistant in your terminal)

---

## How to use after AntiX Core install

After the base AntiX Core installer finishes and you reboot to a terminal,
connect your ethernet cable and run these three commands:

```bash
# 1. Download the install script
wget https://raw.githubusercontent.com/todddrum/Antix_Base_Install/master/install.sh

# 2. Run it as root
sudo bash install.sh

# 3. Reboot into the desktop
sudo reboot
```

The script takes care of everything else. When the desktop comes up:

1. Open **Firefox** (right-click desktop → Firefox)
2. Log into **claude.ai** with your Anthropic Pro account
3. Open a terminal (`Super+Enter`) and run: `claude`
4. Follow the OAuth prompt — Claude Code is now active in your terminal

---

## Keyboard shortcuts

| Key             | Action        |
|-----------------|---------------|
| Super+Enter     | Terminal      |
| Super+R         | App launcher  |
| Super+E         | File manager  |
| Super+B         | Firefox       |
| PrtScr          | Screenshot    |
| Right-click desktop | Menu      |

---

## ESP32 quick-start (after install)

```bash
source ~/esptool_env/bin/activate
esptool chip_id
```

Or open **Thonny** from the desktop menu → connect to MicroPython REPL directly.

---

## Files

| File          | Purpose                           |
|---------------|-----------------------------------|
| install.sh    | Main install script (run as root) |
| PROGRESS.md   | Project checklist and notes       |
