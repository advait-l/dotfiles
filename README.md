# Vim Configuration

My personal Vim and Neovim configurations.

## Structure

```
vimconfig/
├── vim/      # Classic Vim configuration (Vundle)
└── neovim/   # Neovim configuration (lazy.nvim)
```

## Vim Setup

Classic Vim configuration using Vundle plugin manager.

### Installation

1. Install Vundle:
   ```bash
   git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
   ```

2. Copy vimrc:
   ```bash
   ln -s $(pwd)/vim/vimrc ~/.vimrc
   ```

3. Install plugins:
   ```vim
   :PluginInstall
   ```

## Neovim Setup

Modern Neovim configuration based on [kickstart.nvim](https://github.com/folke/kickstart.nvim) using lazy.nvim plugin manager.

### Requirements

- Neovim >= 0.10 (stable)
- Git
- A Nerd Font (optional, for icons)
- ripgrep, fd-find

### Installation

1. Clone/symlink to config directory:
   ```bash
   ln -s $(pwd)/neovim ~/.config/nvim
   ```

2. Start Neovim - plugins will install automatically on first launch.

## License

MIT License - see [neovim/LICENSE.md](neovim/LICENSE.md)