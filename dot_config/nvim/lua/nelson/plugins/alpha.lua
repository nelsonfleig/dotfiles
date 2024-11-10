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
      dashboard.button('SPC sf', '󰱼  > Find File', '<cmd>Telescope find_files<CR>'),
      dashboard.button('n', '  > New File', '<cmd>ene<CR>'),
      dashboard.button('SPC \\', '  > Toggle file explorer', '<cmd>Neotree toggle<CR>'),
      dashboard.button('SPC fs', '  > Find Word', '<cmd>Telescope live_grep<CR>'),
      dashboard.button('q', ' > Quit NVIM', '<cmd>qa<CR>'),
    }

    -- Send config to alpha
    alpha.setup(dashboard.opts)

    -- Disable folding on alpha buffer
    vim.cmd [[autocmd FileType alpha setlocal nofoldenable]]
  end,
}
