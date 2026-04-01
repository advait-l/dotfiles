-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'nvimdev/lspsaga.nvim',
    event = 'LspAttach',
    opts = {
      lightbulb = { enable = false },
    },
    config = function(_, opts)
      require('lspsaga').setup(opts)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('lspsaga-keymaps', { clear = false }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc })
          end
          map('gh', '<cmd>Lspsaga hover_doc<CR>', 'Hover Documentation')
          map('gd', '<cmd>Lspsaga peek_definition<CR>', 'Peek Definition')
          map('gD', '<cmd>Lspsaga goto_definition<CR>', 'Goto Definition')
          map('gr', '<cmd>Lspsaga finder<CR>', 'Finder')
          map('gR', '<cmd>Lspsaga rename<CR>', 'Rename')
          map('<leader>ca', '<cmd>Lspsaga code_action<CR>', 'Code Action')
          map('<leader>o', '<cmd>Lspsaga outline<CR>', 'Outline')
        end,
      })
    end,
  },
}
