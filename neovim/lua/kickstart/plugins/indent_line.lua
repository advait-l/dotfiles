return {
  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = {
        char = '│',
        tab_char = '│',
      },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
      },
      exclude = {
        filetypes = {
          'help',
          'dashboard',
          'lazy',
          'mason',
          'NvimTree',
        },
      },
    },
  },
}
