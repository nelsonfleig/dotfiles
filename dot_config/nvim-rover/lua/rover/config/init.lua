-- [[ Global Settings ]]
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- copy to system clipboard, even in tmux and ssh
vim.g.clipboard = 'osc52'

-- Set default colorscheme
vim.cmd.colorscheme('habamax')

require('rover.config.options')
require('rover.config.keymaps')
require('rover.config.lazy')
