#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Map: package -> dotfile path relative to HOME
# For directories, prefix with dir:path
declare -A LINKS=(
  ["zsh/.zshrc"]=".zshrc"
  ["tmux/.tmux.conf"]=".tmux.conf"
  ["vim/.vimrc"]=".vimrc"
)
declare -A DIR_LINKS=(
  ["nvim"]=".config/nvim"
)

backup_existing() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$target" "$BACKUP_DIR/"
    echo "  Backed up existing $target -> $BACKUP_DIR"
  fi
}

link_file() {
  local src="$DOTFILES_DIR/$1"
  local target="$HOME/$2"

  if [[ ! -e "$src" ]]; then
    echo "  Source missing, skipping: $src"
    return
  fi

  backup_existing "$target"
  mkdir -p "$(dirname "$target")"
  ln -sfn "$src" "$target"
  echo "  Linked $target -> $src"
}

link_dir() {
  local src="$DOTFILES_DIR/$1"
  local target="$HOME/$2"

  if [[ ! -d "$src" ]]; then
    echo "  Source directory missing, skipping: $src"
    return
  fi

  backup_existing "$target"
  mkdir -p "$(dirname "$target")"
  ln -sfn "$src" "$target"
  echo "  Linked $target -> $src"
}

echo "Installing dotfiles from $DOTFILES_DIR"
echo "Backups will be stored in $BACKUP_DIR"
echo

for src in "${!LINKS[@]}"; do
  link_file "$src" "${LINKS[$src]}"
done

for src in "${!DIR_LINKS[@]}"; do
  link_dir "$src" "${DIR_LINKS[$src]}"
done

echo
echo "Done."
echo "If you use Powerlevel10k, run: p10k configure"
echo "Remember to set git user info:"
echo "  git config --global user.name 'Your Name'"
echo "  git config --global user.email 'your@email.com'"
