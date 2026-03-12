# Dotfiles3 — rinooze

> Hyprland rice for Arch Linux  
> WM: Hyprland · Bar: Waybar · Shell: Zsh · Term: Alacritty · Launcher: Rofi

---

## 📸 Preview

<!-- Add screenshots here -->
~/Dotfiles3/1
~/Dotfiles3/2
~/Dotfiles3/3
~/Dotfiles3/4
~/Dotfiles3/5
~/Dotfiles3/6

---

## 📁 Structure

```
Dotfiles3/
├── .config/
│   ├── alacritty/
│   ├── cava/
│   ├── geany/
│   ├── hypr/
│   ├── nvim/
│   ├── nwg-dock-hyprland/
│   ├── nwg-look/
│   ├── rofi/
│   ├── swaync/
│   ├── waybar/
│   └── waypaper/
├── .zsh/
├── wallpapers/        ← symlinked to ~/Pictures/Wallpapers/
├── install.sh         ← full automated install
├── link.sh            ← only symlinks dotfiles
└── README.md
```

---

## 🚀 Install

### Full install (packages + dotfiles)
```bash
git clone https://github.com/shizukutakahashi55-del/Dotfiles3.git ~/Dotfiles3
cd ~/Dotfiles3
chmod +x install.sh
./install.sh
```

### Only symlink configs (if packages already installed)
```bash
chmod +x link.sh
./link.sh
```

---

## 📦 What gets installed

| Category | Packages |
|---|---|
| WM / Display | hyprland, hyprpaper, hypridle, hyprlock, xdg-desktop-portal-hyprland |
| Bar | waybar |
| Notifications | swaync |
| Launcher | rofi-wayland |
| Terminal | alacritty |
| Shell | zsh, zsh-autosuggestions, zsh-syntax-highlighting, starship |
| Visualizer | cava |
| Dock | nwg-dock-hyprland |
| GTK theme | nwg-look |
| Wallpaper | waypaper |
| Editor | neovim |
| File manager | thunar, gvfs |
| Media | vlc, ffmpeg |
| Images | xnview (AUR) |
| Music | spotify (AUR), spicetify-cli (AUR) |
| Gaming | steam, lutris, protonplus (AUR), prismlauncher (AUR) |
| Gaming deps | wine, winetricks, gamemode, mangohud, lib32-* |
| Fonts | ttf-jetbrains-mono-nerd, noto-fonts-emoji |
| Polkit | polkit-gnome |

---

## 🔗 Wallpapers

Wallpapers live at `~/Pictures/Wallpapers/`. The repo contains a `wallpapers/` symlink pointing there. Add your own images to that folder and set them via `waypaper`. Updated version is managed with hyprpaper and quickshell to replace walls.

---

## ⚠️ Notes

- Tested on **Arch Linux** with **Hyprland**
- AUR packages require an AUR helper — `yay` is installed automatically if not found
- Spicetify is applied after Spotify install; run `spicetify apply` manually if it fails
- Gaming: Proton GE can be managed from **ProtonPlus** after install
