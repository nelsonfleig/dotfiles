-- Highlight, edit, and navigate code
return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    opts = {
        -- A list of parser names, or "all" (the listed parsers MUST always be installed)
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", "javascript", "typescript", "jsdoc", "python", "bash" },
        sync_install = false,
        auto_install = true,
        indent = { enable = true },
        highlight = {
            -- `false` will disable the whole extension
            enable = true,
        },
    },
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}
-- vim: ts=2 sts=2 sw=2 et
