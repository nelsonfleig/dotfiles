-- [[ Global Settings ]]
-- Set <space> as the leader key
-- ch NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- recommended settings from nvim-tree documentation
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- controls formatting on save
vim.g.autoformat = true

-- whether to show the code context for nvim-treesitter-context
vim.g.show_ts_context = true

-- controls whether to show relative line numbers
vim.g.show_relative_number = true

-- copy to system clipboard, even in tmux and ssh
vim.g.clipboard = 'osc52'

-- To fix pyenv/pyright issues: https://github.com/neovim/nvim-lspconfig/issues/717
-- vim.env.PYENV_VERSION = vim.fn.system('pyenv version'):match '(%S+)%s+%(.-%)'
