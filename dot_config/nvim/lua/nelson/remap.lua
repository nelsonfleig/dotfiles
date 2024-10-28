vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Save and Quit
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<leader>wq", ":wq<CR>")

-- Buffer Navigation
vim.keymap.set("n", "<leader>bn", ":bnext<CR>")
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>")
vim.keymap.set("n", "<leader>bd", ":bdelete<CR>")

-- Window Navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Open netrw in the current directory (here until I get a better file explorer)
vim.keymap.set("n", "<leader>e", ":Explore<CR>")     -- Open netrw in the current window
vim.keymap.set("n", "<leader>ve", ":Vexplore<CR>")   -- Open netrw in a vertical split
vim.keymap.set("n", "<leader>se", ":Sexplore<CR>")   -- Open netrw in a horizontal split


-- Format current buffer
vim.keymap.set("n", "<leader>fm", vim.lsp.buf.format, { noremap = true, silent = true })

-- Move highlighted text
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Append line below to current line
vim.keymap.set("n", "J", "mzJ`z")

-- Scroll and maintain cursor in center
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Paste and substitute text without losing the current paste buffer
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Yank into system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Just don't use this
vim.keymap.set("n", "Q", "<nop>")

-- Requires tmux-sessionizer
-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
--
-- Quick fix navigation (not sure what this is)
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Make current file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
