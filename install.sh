#!/usr/bin/env bash
# =============================================================================
# Dotfiles3 — Full Install Script
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
  info "Updating system..."
  sudo pacman -Syu --noconfirm

  info "Installing core packages..."
  sudo pacman -S --needed --noconfirm \
    hyprland \
    hyprpaper \
    hypridle \
    hyprlock \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    xdg-user-dirs \
    qt5-wayland \
    qt6-wayland \
    polkit-gnome \
    waybar \
    alacritty \
    rofi-wayland \
    cava \
    neovim \
    zsh \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    starship \
    thunar \
    gvfs \
    gvfs-mtp \
    tumbler \
    ffmpegthumbnailer \
    vlc \
    ffmpeg \
    mpv \
    imv \
    wl-clipboard \
    cliphist \
    brightnessctl \
    playerctl \
    pamixer \
    pipewire \
    pipewire-alsa \
    pipewire-pulse \
    pipewire-jack \
    wireplumber \
    pavucontrol \
    bluez \
    bluez-utils \
    blueman \
    networkmanager \
    network-manager-applet \
    nm-connection-editor \
    nwg-look \
    gtk3 \
    gtk4 \
    adwaita-icon-theme \
    gnome-themes-extra \
    ttf-jetbrains-mono-nerd \
    ttf-nerd-fonts-symbols \
    noto-fonts \
    noto-fonts-emoji \
    noto-fonts-cjk \
    ttf-liberation \
    grim \
    slurp \
    swappy \
    dunst \
    libnotify \
    python \
    python-pip \
    curl \
    wget \
    unzip \
    zip \
    p7zip \
    htop \
    btop \
    git \
    base-devel \
    steam

  success "Core packages installed"
}

# =============================================================================
# AUR Packages
# =============================================================================
install_aur_packages() {
  info "Installing AUR packages..."

  # Media & Apps
  yay -S --needed --noconfirm \
    waypaper \
    swaync \
    nwg-dock-hyprland \
    hyprshot \
    wlogout \
    spotify \
    spicetify-cli \
    xnviewmp \
    nwg-displays

  # Gaming
  yay -S --needed --noconfirm \
    lutris \
    protonplus \
    prismlauncher \
    heroic-games-launcher-bin \
    gamemode \
    lib32-gamemode \
    mangohud \
    lib32-mangohud \
    wine \
    wine-gecko \
    wine-mono \
    winetricks \
    lib32-vulkan-icd-loader \
    vulkan-tools \
    proton-ge-custom-bin

  success "AUR packages installed"
}

# =============================================================================
# Gaming dependencies
# =============================================================================
install_gaming_deps() {
  info "Installing gaming multilib dependencies..."
  sudo pacman -S --needed --noconfirm \
    lib32-mesa \
    lib32-glibc \
    lib32-gcc-libs \
    lib32-libpulse \
    lib32-alsa-lib \
    lib32-alsa-plugins \
    lib32-sdl2 \
    lib32-openal \
    vulkan-radeon \
    lib32-vulkan-radeon \
    vulkan-icd-loader \
    lib32-vulkan-icd-loader 2>/dev/null || \
  sudo pacman -S --needed --noconfirm \
    vulkan-intel \
    lib32-vulkan-intel 2>/dev/null || true

  success "Gaming deps installed"
}

# =============================================================================
# Zsh setup
# =============================================================================
setup_zsh() {
  info "Setting up Zsh as default shell..."
  if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
    success "Default shell changed to Zsh (re-login to apply)"
  else
    success "Zsh already default shell"
  fi
}

# =============================================================================
# Spicetify setup
# =============================================================================
setup_spicetify() {
  info "Configuring Spicetify..."
  if command -v spicetify &>/dev/null && command -v spotify &>/dev/null; then
    spicetify config inject_css 1 replace_colors 1 overwrite_assets 1 inject_theme_js 1 2>/dev/null || true
    spicetify backup 2>/dev/null || true
    spicetify apply 2>/dev/null || warn "Spicetify apply failed — run 'spicetify apply' after launching Spotify once"
    success "Spicetify configured"
  else
    warn "Spotify or Spicetify not found, skipping"
  fi
}

# =============================================================================
# Wallpapers
# =============================================================================
setup_wallpapers() {
  info "Setting up wallpapers directory..."
  mkdir -p "$WALLPAPER_DIR"
  if [ -d "$DOTFILES_DIR/wallpapers" ] && [ "$(ls -A "$DOTFILES_DIR/wallpapers" 2>/dev/null)" ]; then
    cp -rn "$DOTFILES_DIR/wallpapers/"* "$WALLPAPER_DIR/" 2>/dev/null || true
    success "Wallpapers copied to $WALLPAPER_DIR"
  else
    success "Wallpapers directory ready at $WALLPAPER_DIR (add your images there)"
  fi
}

# =============================================================================
# Enable services
# =============================================================================
enable_services() {
  info "Enabling system services..."
  sudo systemctl enable --now NetworkManager 2>/dev/null || true
  sudo systemctl enable --now bluetooth 2>/dev/null || true
  systemctl --user enable --now pipewire 2>/dev/null || true
  systemctl --user enable --now pipewire-pulse 2>/dev/null || true
  systemctl --user enable --now wireplumber 2>/dev/null || true
  success "Services enabled"
}

# =============================================================================
# Symlink dotfiles
# =============================================================================
link_dotfiles() {
  info "Linking dotfiles..."
  bash "$DOTFILES_DIR/link.sh"
}

# =============================================================================
# Main
# =============================================================================
main() {
  banner

  echo -e "${BOLD}This will install all packages and link your dotfiles.${NC}"
  echo -e "Target: ${CYAN}$HOME${NC}"
  echo ""
  read -rp "$(echo -e "${YELLOW}Continue? [y/N]: ${NC}")" confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

  install_yay
  install_pacman_packages
  install_aur_packages
  install_gaming_deps
  setup_zsh
  setup_wallpapers
  enable_services
  link_dotfiles
  setup_spicetify

  echo ""
  success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  success " Install complete! Log out & back in."
  success " Start Hyprland with: Hyprland"
  success "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

main "$@"
