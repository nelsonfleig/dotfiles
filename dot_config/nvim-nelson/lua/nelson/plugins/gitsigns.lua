-- Here is a more advanced example where we pass configuration
-- options to `gitsigns.nvim`. This is equivalent to the following Lua:
--    require('gitsigns').setup({ ... })
--
-- See `:help gitsigns` to understand what the configuration keys do
return { -- Adds git related signs to the gutter, as well as utilities for managing changes
  'lewis6991/gitsigns.nvim',
  opts = {
    signs = {
      add = { text = '+' },
      change = { text = '~' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    current_line_blame = true,
    on_attach = function(buffer)
      local gs = require 'gitsigns'

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
      end

      map('n', '<leader>gb', function()
        gs.blame_line { full = true }
      end, 'Blame Line')
      map('n', '<leader>gB', function()
        gs.blame()
      end, 'Blame Buffer')
      map('n', '<leader>gd', gs.diffthis, 'Diff This')
      map('n', '<leader>gD', function()
        gs.diffthis '~'
      end, 'Diff This ~')
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
