return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "astro",
        "cmake",
        "cpp",
        "graphql",
        "scss",
        "sql",
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
        "tsx",
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)

      -- MDX
      vim.filetype.add({
        extension = {
          mdx = "mdx",
        },
      })

      vim.treesitter.language.register("markdown", "mdx")
    end,
  },
}
