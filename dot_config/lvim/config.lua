-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- Python
lvim.builtin.treesitter.ensure_installed = {
  "python"
}

-- TODO: Check if it is enough to just use flake8
-- local formatters = require("lvim.lsp.null-ls.formatters")
-- formatters.setup { { name = "black" } }

local linters = require("lvim.lsp.null-ls.linters")
linters.setup { { command = "flake8", args = { "--ignore=E203" }, filetypes = { "python" } } }

lvim.format_on_save.enabled = true
lvim.plugins = {
  "AckslD/swenv.nvim",
  "stevearc/dressing.nvim",
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap", "mfussenegger/nvim-dap-python", --optional
      { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
    },
    lazy = false,
    branch = "regexp", -- This is the regexp branch, use this for the new version
    config = function()
      require("venv-selector").setup()
    end,
    keys = {
      { ",v", "<cmd>VenvSelect<cr>" },
    },
  },

  {
    "f-person/git-blame.nvim",
    event = "BufRead",
    config = function()
      vim.cmd "highlight default link gitblame SpecialComment"
      require("gitblame").setup { enabled = false }
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
}

require('swenv').setup({
  post_set_venv = function()
    vim.cmd("LspRestart")
  end
})

lvim.builtin.which_key.mappings["C"] = {
  name = "Python",
  c = { "<cmd>lua require('swenv.api').pick_venv()<cr>", "Choose Env" }
}

vim.opt.relativenumber = true
vim.opt.shell = "/bin/zsh"
