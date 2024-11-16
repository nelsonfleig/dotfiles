return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'json',
        'yaml',
        'toml',
        'dockerfile',
        'css',
        'javascript',
        'typescript',
        'tsx',
        'python',
      },
      auto_install = true,
      highlight = {
        enable = true,
      },
      indent = { enable = true },
    },
  },
}

