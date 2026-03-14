#!/usr/bin/env bash
# =============================================================================
# Dotfiles3 — Full Install Script (Optimized for rinooze)
# Author: rinooze
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${CYAN}${BOLD}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}${BOLD}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}${BOLD}[WARN]${NC} $*"; }
error()   { echo -e "${RED}${BOLD}[ERROR]${NC} $*"; exit 1; }

banner() {
  echo -e "${CYAN}"
  echo "  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗ ██████╗ "
  echo "  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝╚════██╗"
  echo "  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗ █████╔╝"
  echo "  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║ ╚═══██╗"
  echo "  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║██████╔╝"
  echo "  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝╚═════╝ "
  echo -e "${NC}"
  echo -e "  ${BOLD}Hyprland rice installer for Arch Linux — rinooze${NC}"
  echo ""
}

# =============================================================================
# AUR Helper
# =============================================================================
install_yay() {
  if ! command -v yay &>/dev/null; then
    info "Installing yay (AUR helper)..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
    success "yay installed"
  else
    success "yay already installed"
  fi
}

# =============================================================================
# Pacman Packages
# =============================================================================
install_pacman_packages() {
  info "Updating system and installing Core + NVIDIA packages..."
  sudo pacman -Syu --noconfirm

  sudo pacman -S --needed --noconfirm \
    hyprland nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings \
    hyprpaper hypridle hyprlock xdg-desktop-portal-hyprland xdg-desktop-portal-gtk \
    waybar alacritty kitty rofi-wayland cava neovim zsh starship \
    zsh-autosuggestions zsh-syntax-highlighting \
    thunar gvfs gvfs-mtp tumbler ffmpegthumbnailer \
    vlc ffmpeg mpv imv wl-clipboard cliphist brightnessctl playerctl \
    pamixer pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber pavucontrol \
    bluez bluez-utils blueman networkmanager network-manager-applet nm-connection-editor \
    nwg-look gtk3 gtk4 adwaita-icon-theme gnome-themes-extra \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji noto-fonts-cjk \
    grim slurp swappy dunst libnotify python python-pip \
    curl wget unzip zip p7zip htop btop git base-devel

  success "Core packages installed"
}

# =============================================================================
# AUR Packages
# =============================================================================
install_aur_packages() {
  info "Installing AUR packages..."
  # Separamos en grupos para evitar que un fallo detenga todo
  yay -S --needed --noconfirm waypaper swaync nwg-displays wlogout || warn "Some UI tools failed"
  yay -S --needed --noconfirm spotify spicetify-cli || warn "Spotify tools failed"
  
  # Gaming - Agregado gpu-screen-recorder que usas en tus binds
  yay -S --needed --noconfirm \
    lutris protonplus prismlauncher heroic-games-launcher-bin \
    gamemode lib32-gamemode mangohud lib32-mangohud \
    wine-staging winetricks-git vkd3d-proton-bin \
    gpu-screen-recorder-git hyprpicker-git

  success "AUR packages installed"
}

# =============================================================================
# Gaming dependencies (Multilib)
# =============================================================================
install_gaming_deps() {
  info "Installing multilib dependencies for gaming..."
  # Forzamos la instalación de librerías de 32 bits esenciales para Steam/Warframe
  sudo pacman -S --needed --noconfirm \
    lib32-mesa lib32-libglvnd lib32-vulkan-icd-loader \
    lib32-openal lib32-libpulse lib32-sdl2 lib32-libnm \
    steam vulkan-tools

  success "Gaming deps installed"
}

# =============================================================================
# Spicetify setup
# =============================================================================
setup_spicetify() {
  info "Configuring Spicetify..."
  # Necesitas dar permisos a la carpeta de Spotify para que spicetify funcione
  sudo chmod a+wr /opt/spotify
  sudo chmod a+wr /opt/spotify/Apps -R
  
  if command -v spicetify &>/dev/null; then
    spicetify backup apply || warn "Run 'spicetify backup apply' manually after opening Spotify"
    success "Spicetify configured"
  fi
}

# ... (El resto de funciones setup_zsh, setup_wallpapers, enable_services, link_dotfiles se mantienen igual) ...

setup_zsh() {
  info "Setting up Zsh as default shell..."
  if [ "$SHELL" != "$(which zsh)" ]; then
    sudo chsh -s "$(which zsh)" "$USER"
    success "Default shell changed to Zsh"
  else
    success "Zsh already default shell"
  fi
}

setup_wallpapers() {
  info "Setting up wallpapers directory..."
  mkdir -p "$WALLPAPER_DIR"
  if [ -d "$DOTFILES_DIR/wallpapers" ]; then
    cp -rn "$DOTFILES_DIR/wallpapers/"* "$WALLPAPER_DIR/" 2>/dev/null || true
  fi
}

enable_services() {
  info "Enabling system services..."
  sudo systemctl enable --now NetworkManager
  sudo systemctl enable --now bluetooth
  success "Services enabled"
}

link_dotfiles() {
  info "Linking dotfiles..."
  if [ -f "$DOTFILES_DIR/link.sh" ]; then
    bash "$DOTFILES_DIR/link.sh"
  else
    warn "link.sh not found, skipping symlinks"
  fi
}

main() {
  banner
  echo -e "Target: ${CYAN}$HOME${NC}"
  read -rp "$(echo -e "${YELLOW}Continue? [y/N]: ${NC}")" confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

  install_yay
  install_pacman_packages
  install_gaming_deps
  install_aur_packages
  setup_zsh
  setup_wallpapers
  enable_services
  link_dotfiles
  setup_spicetify

  success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  success " Install complete! Please reboot."
  success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

main "$@"