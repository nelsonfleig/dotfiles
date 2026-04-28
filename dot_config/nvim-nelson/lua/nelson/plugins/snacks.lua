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
    gitbrowse = { enabled = true },
    lazygit = { enabled = true },
    dashboard = {
      preset = {
        header = [[
  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝

                 [ @nelsonfleig ]
        ]],
        keys = {
          { icon = ' ', key = 'f', desc = 'Find File', action = function() require('telescope.builtin').find_files() end },
          { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
          { icon = ' ', key = 'r', desc = 'Recent Files', action = function() require('telescope.builtin').oldfiles() end },
          { icon = ' ', key = 'g', desc = 'Find Text', action = function() require('telescope.builtin').live_grep() end },
          { icon = ' ', key = 'c', desc = 'Config', action = function() require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') }) end },
          { icon = ' ', key = 's', desc = 'Restore Session', action = function() require('persistence').load() end },
          { icon = '󰒲 ', key = 'l', desc = 'Lazy', action = ':Lazy' },
          { icon = ' ', key = '\\', desc = 'File Explorer', action = ':Neotree toggle' },
          { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
        },
      },
    },
  },
  keys = {
    -- Git
    {
      '<leader>gl',
      function() Snacks.lazygit() end,
      desc = 'Lazygit',
    },
    {
      '<leader>gx',
      function() Snacks.gitbrowse() end,
      desc = 'Git Browse',
      mode = { 'n', 'v' },
    },
    {
      '<leader>gX',
      function() Snacks.gitbrowse({ open = function(url) vim.fn.setreg('+', url) end, notify = false }) end,
      desc = 'Git Browse (copy URL)',
      mode = { 'n', 'v' },
    },
    -- Buffers
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
