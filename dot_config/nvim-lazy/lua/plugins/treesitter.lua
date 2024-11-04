return {
  "nvim-treesitter/nvim-treesitter",
  opts_extend = { "ensure_installed" },
  opts = {
    ensure_installed = {
      "bash",
      "json",
      "yaml",
      "toml",
      "dockerfile",
      "css",
      "javascript",
      "typescript",
      "tsx",
      "python",
    },
  },
}
