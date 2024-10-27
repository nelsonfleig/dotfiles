require("nelson.set")
require("nelson.remap")
require("nelson.lazy_init")

local augroup = vim.api.nvim_create_augroup
local NelsonGroup = augroup('Nelson', {})
local autocmd = vim.api.nvim_create_autocmd

autocmd('BufEnter', {
    group = NelsonGroup,
    callback = function()
        vim.cmd.colorscheme("tokyonight-night")
    end
})
