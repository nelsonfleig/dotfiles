vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.wrap = false

-- Spaces instead of tabs. Indent by 4
vim.opt.expandtab = true
vim.opt.tabstop = 4        
vim.opt.shiftwidth = 4        
        
-- Synchronize with system clipboard
vim.opt.clipboard = "unnamedplus"

-- Maintain cursor in the middle when scrolling long files
vim.opt.scrolloff = 999

-- Ignore end of line when in visual block mode
vim.opt.virtualedit = "block"

-- Show results of substitute command in a preview window
vim.opt.inccommand = "split"

-- Ignore cases in autocomplete
vim.opt.ignorecase = true

vim.opt.termguicolors = true

vim.g.mapleader = " "
