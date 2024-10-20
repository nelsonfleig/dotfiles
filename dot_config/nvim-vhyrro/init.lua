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

-- Sets up lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    "rebelot/kanagawa.nvim"
})

-- same as running `:colorscheme kanagawa-wave`
vim.cmd.colorscheme("kanagawa-wave")

