return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
        -- A list of parser names, or "all" (the listed parsers MUST always be installed)
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "javascript", "typescript", "jsdoc", "bash" },
        sync_install = false,
        auto_install = true,
        indent = { enable = true },
        highlight = {
            -- `false` will disable the whole extension
            enable = true,
        },
    },
}
