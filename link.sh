#!/usr/bin/env bash
# =============================================================================
# Dotfiles3 — Symlink Script
# Author: rinooze
# =============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${CYAN}${BOLD}[LINK]${NC} $*"; }
success() { echo -e "${GREEN}${BOLD}[OK]${NC}   $*"; }
warn()    { echo -e "${YELLOW}${BOLD}[SKIP]${NC} $*"; }

# Create symlink helper — backs up existing, then links
make_link() {
  local src="$1"
  local dst="$2"

  mkdir -p "$(dirname "$dst")"

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
      warn "$dst already linked, skipping"
      return
    fi
    local backup="${dst}.bak.$(date +%s)"
    mv "$dst" "$backup"
    warn "Backed up existing $dst → $backup"
  fi

  ln -sf "$src" "$dst"
  success "$dst → $src"
}

echo ""
echo -e "${BOLD}  Linking dotfiles for rinooze...${NC}"
echo ""

# .config directories
for dir in \
  alacritty \
  cava \
  geany \
  hypr \
  nvim \
  nwg-dock-hyprland \
  nwg-look \
  rofi \
  swaync \
  waybar \
  waypaper
do
  src="$DOTFILES_DIR/.config/$dir"
  dst="$CONFIG_DIR/$dir"
  if [ -d "$src" ]; then
    make_link "$src" "$dst"
  else
    warn "$src not found, skipping"
  fi
done

# Zsh
make_link "$DOTFILES_DIR/.zsh/.zshrc"  "$HOME/.zshrc"
make_link "$DOTFILES_DIR/.zsh/.zshenv" "$HOME/.zshenv"
make_link "$DOTFILES_DIR/.zsh/.zprofile" "$HOME/.zprofile"

# Wallpapers — symlink repo folder into Pictures
mkdir -p "$WALLPAPER_DIR"
if [ -d "$DOTFILES_DIR/wallpapers" ]; then
  info "Wallpapers dir: $WALLPAPER_DIR (not symlinked — copy manually)"
fi

echo ""
echo -e "${GREEN}${BOLD}All dotfiles linked!${NC}"
echo ""
