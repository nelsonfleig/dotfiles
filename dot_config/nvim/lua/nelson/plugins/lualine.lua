return {
  'nvim-lualine/lualine.nvim',
  init = function()
    vim.g.lualine_laststatus = vim.o.laststatus
    if vim.fn.argc(-1) > 0 then
      -- set an empty statusline till lualine loads
      vim.o.statusline = ' '
    else
      -- hide the statusline on the starter page
      vim.o.laststatus = 0
    end
  end,
  config = function()
    -- to check pending updates available in lazy
    local lazy_status = require 'lazy.status'
    vim.o.laststatus = vim.g.lualine_laststatus
    require('lualine').setup {
      options = {
        theme = 'tokyonight-night',
        globalstatus = vim.o.laststatus == 3,
        disabled_filetypes = { statusline = { 'dashboard', 'alpha', 'ministarter' } },
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch' },
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = '#ff9e64' },
          },
          { 'encoding' },
          { 'fileformat' },
          { 'filetype' },
        },
      },
      extensions = { 'neo-tree', 'lazy' },
    }
  end,
}
