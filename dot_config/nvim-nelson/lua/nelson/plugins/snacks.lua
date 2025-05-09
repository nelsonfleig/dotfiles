-- Provides a collection of small QoL plugins for Neovim.
return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    notifier = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
  },
  keys = {
    {
      '<leader>bd',
      function()
        Snacks.bufdelete() -- deletes current buffer without disrupting window layout
      end,
      desc = 'Delete Buffer',
    },
    {
      '<leader>bo',
      function()
        Snacks.bufdelete.other()
      end,
      desc = 'Delete Other Buffers',
    },
  },
  config = function(_, opts)
    require('snacks').setup(opts)
    local toggle_relative_numbers = function()
      return Snacks.toggle {
        name = 'Relative Line Numbers',
        get = function()
          return vim.g.show_relative_number
        end,
        set = function(state)
          if state == true then
            vim.cmd 'set relativenumber'
          else
            vim.cmd 'set norelativenumber'
          end
          vim.g.show_relative_number = state
        end,
      }
    end

    local toggle_indent_lines = function()
      return Snacks.toggle {
        name = 'Indent Lines',
        get = function()
          return Snacks.indent.enabled
        end,
        set = function(state)
          if state == true then
            Snacks.indent.enable()
          else
            Snacks.indent.disable()
          end
        end,
      }
    end
    toggle_relative_numbers():map '<leader>ur'
    toggle_indent_lines():map '<leader>ui'
  end,
}
