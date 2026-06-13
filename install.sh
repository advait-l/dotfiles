#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Config ----------------------------------------------------------------------

# Use regular arrays for bash 3.2 compatibility (macOS)
LINK_SOURCES=("zsh/.zshrc" "tmux/.tmux.conf" "vim/.vimrc")
LINK_TARGETS=(".zshrc" ".tmux.conf" ".vimrc")

DIR_LINK_SOURCES=("nvim")
DIR_LINK_TARGETS=(".config/nvim")

# Helpers ---------------------------------------------------------------------

info() {
  echo "[dotfiles] $*"
}

warn() {
  echo "[dotfiles] WARNING: $*" >&2
}

backup_existing() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$target" "$BACKUP_DIR/"
    info "Backed up existing $target -> $BACKUP_DIR"
  fi
}

link_file() {
  local src="$DOTFILES_DIR/$1"
  local target="$HOME/$2"

  if [[ ! -e "$src" ]]; then
    warn "Source missing, skipping: $src"
    return
  fi

  backup_existing "$target"
  mkdir -p "$(dirname "$target")"
  ln -sfn "$src" "$target"
  info "Linked $target -> $src"
}

link_dir() {
  local src="$DOTFILES_DIR/$1"
  local target="$HOME/$2"

  if [[ ! -d "$src" ]]; then
    warn "Source directory missing, skipping: $src"
    return
  fi

  backup_existing "$target"
  mkdir -p "$(dirname "$target")"
  ln -sfn "$src" "$target"
  info "Linked $target -> $src"
}

# OS detection ----------------------------------------------------------------

detect_os() {
  case "$(uname -s)" in
    Linux*)     echo "linux" ;;
    Darwin*)    echo "macos" ;;
    *)          echo "unknown" ;;
  esac
}

OS="$(detect_os)"

# Package management ----------------------------------------------------------

detect_pkg_manager() {
  if [[ "$OS" == "macos" ]]; then
    if command -v brew >/dev/null 2>&1; then
      echo "brew"
    else
      echo "none"
    fi
  else
    if command -v apt-get >/dev/null 2>&1; then
      echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
      echo "dnf"
    elif command -v pacman >/dev/null 2>&1; then
      echo "pacman"
    else
      echo "none"
    fi
  fi
}

PKG_MANAGER="$(detect_pkg_manager)"

install_pkg() {
  local pkg="$1"
  info "Installing $pkg via $PKG_MANAGER..."
  case "$PKG_MANAGER" in
    apt)     sudo apt-get update -qq && sudo apt-get install -y "$pkg" ;;
    dnf)     sudo dnf install -y "$pkg" ;;
    pacman)  sudo pacman -S --noconfirm "$pkg" ;;
    brew)    brew install "$pkg" ;;
    *)       warn "No supported package manager found. Please install $pkg manually." && return 1 ;;
  esac
}

ensure_cmd() {
  local cmd="$1"
  local pkg="${2:-$1}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    install_pkg "$pkg"
  else
    info "$cmd is already installed"
  fi
}

# Core dependencies -----------------------------------------------------------

install_core_dependencies() {
  info "Installing core dependencies..."

  ensure_cmd git git
  ensure_cmd curl curl
  ensure_cmd zsh zsh
  ensure_cmd tmux tmux
  ensure_cmd rg ripgrep

  # fd is packaged differently across distros
  if ! command -v fd >/dev/null 2>&1; then
    if [[ "$PKG_MANAGER" == "apt" ]]; then
      install_pkg fd-find
      # Ubuntu/Debian installs the binary as fdfind; make it available as fd
      if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
        sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
        info "Created fd symlink for fdfind"
      fi
    else
      # macOS and most other distros use the package name 'fd'
      install_pkg fd
    fi
  else
    info "fd is already installed"
  fi
}

# Neovim ----------------------------------------------------------------------

nvim_version() {
  nvim --version 2>/dev/null | head -n 1 | sed -E 's/.*v([0-9]+\.[0-9]+).*/\1/'
}

version_ge() {
  # Returns 0 if $1 >= $2 (portable version comparison)
  # Works on both macOS (BSD) and Linux (GNU)
  awk -v v1="$1" -v v2="$2" 'BEGIN {
    split(v1, a, ".");
    split(v2, b, ".");
    for (i = 1; i <= 2; i++) {
      if (a[i]+0 > b[i]+0) exit 0;
      if (a[i]+0 < b[i]+0) exit 1;
    }
    exit 0;
  }'
}

install_nvim_from_release() {
  info "Installing Neovim from GitHub release..."

  local arch
  arch="$(uname -m)"
  local tarball_arch=""
  case "$arch" in
    x86_64)  tarball_arch="linux-x86_64" ;;
    aarch64) tarball_arch="linux-arm64" ;;
    arm64)   tarball_arch="linux-arm64" ;;
    *)       warn "Unsupported architecture: $arch" && return 1 ;;
  esac

  local tmpdir
  tmpdir="$(mktemp -d)"

  local latest_url extracted_dir
  latest_url="https://github.com/neovim/neovim/releases/latest/download/nvim-${tarball_arch}.tar.gz"
  extracted_dir="/opt/nvim-${tarball_arch}"

  curl -fsSL -o "$tmpdir/nvim.tar.gz" "$latest_url"
  sudo rm -rf /opt/nvim "$extracted_dir"
  sudo tar -C /opt -xzf "$tmpdir/nvim.tar.gz"
  sudo mv "$extracted_dir" /opt/nvim
  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
  rm -rf "$tmpdir"
  info "Neovim installed to /usr/local/bin/nvim"
}

ensure_nvim() {
  info "Checking Neovim..."

  local current_version
  current_version="$(nvim_version 2>/dev/null || true)"

  if command -v nvim >/dev/null 2>&1 && [[ -n "$current_version" ]] && version_ge "$current_version" "0.10"; then
    info "Neovim $current_version is already installed (>= 0.10)"
    return
  fi

  if [[ "$OS" == "macos" ]]; then
    install_pkg neovim
  else
    install_nvim_from_release
  fi
}

# Oh-My-Zsh and Powerlevel10k -------------------------------------------------

install_ohmyzsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    info "Oh-My-Zsh is already installed"
  else
    info "Installing Oh-My-Zsh..."
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  fi
}

install_powerlevel10k() {
  local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [[ -d "$p10k_dir" ]]; then
    info "Powerlevel10k is already installed"
  else
    info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
  fi
}

# Dotfiles symlinks -----------------------------------------------------------

install_dotfiles() {
  info "Linking dotfiles..."
  info "Backups will be stored in $BACKUP_DIR"

  for i in "${!LINK_SOURCES[@]}"; do
    link_file "${LINK_SOURCES[$i]}" "${LINK_TARGETS[$i]}"
  done

  for i in "${!DIR_LINK_SOURCES[@]}"; do
    link_dir "${DIR_LINK_SOURCES[$i]}" "${DIR_LINK_TARGETS[$i]}"
  done
}

# Neovim plugins --------------------------------------------------------------

install_nvim_plugins() {
  info "Installing Neovim plugins (this may take a while)..."
  nvim --headless "+Lazy! sync" +qa
  info "Neovim plugins installed"
}

# Shell -----------------------------------------------------------------------

change_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh)"
  if [[ "$SHELL" == "$zsh_path" ]]; then
    info "zsh is already the default shell"
    return
  fi

  info "Changing default shell to zsh..."

  # On macOS, the shell must be listed in /etc/shells
  if [[ "$OS" == "macos" ]] && ! grep -qF "$zsh_path" /etc/shells 2>/dev/null; then
    warn "$zsh_path is not in /etc/shells"
    info "Adding $zsh_path to /etc/shells (requires sudo)..."
    echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
  fi

  chsh -s "$zsh_path"
}

# Main ------------------------------------------------------------------------

main() {
  info "Detected OS: $OS"
  info "Detected package manager: $PKG_MANAGER"

  if [[ "$OS" == "unknown" ]]; then
    warn "Unsupported OS. This script supports Linux and macOS."
    exit 1
  fi

  if [[ "$PKG_MANAGER" == "none" ]]; then
    warn "No supported package manager found."
    if [[ "$OS" == "macos" ]]; then
      warn "Install Homebrew first: https://brew.sh"
    fi
    exit 1
  fi

  install_core_dependencies
  ensure_nvim
  install_ohmyzsh
  install_powerlevel10k
  install_dotfiles
  install_nvim_plugins

  if [[ "${DOTFILES_CHSH:-}" == "yes" ]]; then
    change_default_shell
  fi

  echo
  info "Setup complete!"
  echo
  echo "Next steps:"
  echo "  1. Install a Nerd Font for the best prompt experience:"
  echo "     https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k"
  echo "  2. Run 'p10k configure' to generate ~/.p10k.zsh"
  echo "  3. Set git user info:"
  echo "     git config --global user.name 'Your Name'"
  echo "     git config --global user.email 'your@email.com'"
  echo
  echo "To make zsh the default shell, run:"
  echo "  chsh -s \$(command -v zsh)"
  echo "Or rerun this script with DOTFILES_CHSH=yes"
}

main "$@"
