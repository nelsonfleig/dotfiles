return {
  'goolord/alpha-nvim',
  event = 'VimEnter',
  config = function()
    local alpha = require 'alpha'
    local dashboard = require 'alpha.themes.dashboard'
    local logo = [[
	  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
	  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
	  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
	  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
	  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
	  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝

	                   [ @nelsonfleig ]
    ]]
    -- Add vertical padding
    logo = string.rep('\n', 8) .. logo .. '\n\n'

    dashboard.section.header.val = vim.split(logo, '\n')

    -- Set menu
    -- TODO: Update these buttons keyamps
    dashboard.section.buttons.val = {
      dashboard.button('f', ' ' .. ' Find file', '<cmd>lua require("telescope.builtin").find_files()<cr>'),
      dashboard.button('n', ' ' .. ' New file', '<cmd> ene <BAR> startinsert <cr>'),
      dashboard.button('r', ' ' .. ' Recent files', '<cmd>lua require("telescope.builtin").oldfiles()<cr>'),
      dashboard.button('g', ' ' .. ' Find text', '<cmd>lua require("telescope.builtin").live_grep()<cr>'),
      dashboard.button('c', ' ' .. ' Config', '<cmd><leader>lua require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })<cr>'),
      dashboard.button('s', ' ' .. ' Restore session', '<cmd> lua require("persistence").load() <cr>'),
      dashboard.button('l', '󰒲 ' .. ' Lazy', '<cmd>Lazy<cr>'),
      dashboard.button('\\', ' ' .. ' Toggle file explorer', '<cmd>Neotree toggle<CR>'),
      dashboard.button('q', ' ' .. ' Quit', '<cmd>qa<cr>'),
    }

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.cmd [[autocmd FileType alpha setlocal nofoldenable]]
  end,
}
