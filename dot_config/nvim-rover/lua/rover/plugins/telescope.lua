-- Fuzzy Finder (files, lsp, etc)
return {
  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- requires fzf to be installed
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
    },
    config = function()
      require('telescope').setup({})

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader><leader>', builtin.find_files, { desc = 'Find Files (Root Dir)' })
      vim.keymap.set('n', '<leader>/', builtin.live_grep, { desc = 'Grep (Root Dir)' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
    end,
  },
}
