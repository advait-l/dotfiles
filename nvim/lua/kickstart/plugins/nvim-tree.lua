-- Nvim-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-tree/nvim-tree.lua

return {
  'nvim-tree/nvim-tree.lua',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  lazy = false,
  keys = {
    { '\\', ':NvimTreeToggle<CR>', desc = 'NvimTree toggle', silent = true },
  },
  opts = {
    view = {
      width = {
        min = 30,
        max = -1,
        padding = 1,
      },
    },
    renderer = {
      group_empty = true,
      icons = {
        show = {
          file = true,
          folder = true,
          git = true,
        },
        glyphs = {
          git = {
            unstaged = "●",
            staged = "✚",
            unmerged = "",
            renamed = "",
            untracked = "?",
            deleted = "",
            ignored = "",
          },
        },
      },
    },
    filters = {
      dotfiles = true,
    },
    update_focused_file = {
      enable = true,
    },
  },
}