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
    { 
        "rebelot/kanagawa.nvim",
        config = function()
            -- same as running `:colorscheme kanagawa-wave`
            vim.cmd.colorscheme("kanagawa-wave")
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { 
                    "c", 
                    "lua", 
                    "vim", 
                    "vimdoc", 
                    "query", 
                    "markdown", 
                    "markdown_inline", 
                    "python", 
                    "bash", 
                    "dockerfile", 
                    "gitignore", 
                    "html", 
                    "css", 
                    "json", 
                    "javascript", 
                    "typescript", 
                    "tsx" 
                },
                auto_install = true,
                highlight = {
                    enable = true,
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<Leader>ss",
                        node_incremental = "<Leader>si",
                        scope_incremental = "<Leader>sc",
                        node_decremental = "<Leader>sd",
                    },
                },
                textobjects = {
                    select = {
                        enable = true,
                        -- Automatically jump forward to textobj, similar to targets.vim
                        lookahead = true,

                        keymaps = {
                            -- You can use the capture groups defined in textobjects.scm
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            -- You can optionally set descriptions to the mappings (used in the desc parameter of
                            -- nvim_buf_set_keymap) which plugins like which-key display
                            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                            -- You can also use captures from other query groups like `locals.scm`
                            ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
                        },
                        -- You can choose the select mode (default is charwise 'v')
                        --
                        -- Can also be a function which gets passed a table with the keys
                        -- * query_string: eg '@function.inner'
                        -- * method: eg 'v' or 'o'
                        -- and should return the mode ('v', 'V', or '<c-v>') or a table
                        -- mapping query_strings to modes.
                        selection_modes = {
                            -- ['@parameter.outer'] = 'v', -- charwise (default)
                            -- ['@function.outer'] = 'V', -- linewise
                            -- ['@class.outer'] = '<c-v>', -- blockwise
                        },
                        -- If you set this to `true` (default is `false`) then any textobject is
                        -- extended to include preceding or succeeding whitespace. Succeeding
                        -- whitespace has priority in order to act similarly to eg the built-in
                        -- `ap`.
                        --
                        -- Can also be a function which gets passed a table with the keys
                        -- * query_string: eg '@function.inner'
                        -- * selection_mode: eg 'v'
                        -- and should return true or false
                        include_surrounding_whitespace = true,
                    },
                },
            })
        end
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require("lspconfig")
            lspconfig.clangd.setup({})
        end
    },
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "mason.nvim" }, -- shorter syntax looks for plugin installed in `~/.local/shared`
        config = function()
            local lspconfig = require("mason-lspconfig")
            lspconfig.setup({
                ensure_installed = { "lua_ls", "clangd" },
                handlers = {
                    function (server_name) -- default handler (optional)
                        require("lspconfig")[server_name].setup {}
                    end,
                }
            })
            -- NOTE: This can also be done in the setup function (see above)
            -- lspconfig.setup_handlers {
            --     -- The first entry (without a key) will be the default handler
            --     -- and will be called for each installed server that doesn't have
            --     -- a dedicated handler.
            --     function (server_name) -- default handler (optional)
            --         require("lspconfig")[server_name].setup {}
            --     end,
            -- }
        end
    },
})
