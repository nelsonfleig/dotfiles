return {
  'lewis6991/gitsigns.nvim',
  event = 'VimEnter',
  opts = {
    signs = {
      add = { text = '▎' },
      change = { text = '▎' },
      delete = { text = '' },
      topdelete = { text = '' },
      changedelete = { text = '▎' },
      untracked = { text = '▎' },
    },
    signs_staged = {
      add = { text = '▎' },
      change = { text = '▎' },
      delete = { text = '' },
      topdelete = { text = '' },
      changedelete = { text = '▎' },
    },
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
      end

      -- Hunk navigation (falls back to diff ]c/[c in diff mode)
      map('n', ']h', function()
        if vim.wo.diff then vim.cmd.normal({ ']c', bang = true })
        else gs.nav_hunk('next') end
      end, 'Next Hunk')
      map('n', '[h', function()
        if vim.wo.diff then vim.cmd.normal({ '[c', bang = true })
        else gs.nav_hunk('prev') end
      end, 'Prev Hunk')
      map('n', ']H', function() gs.nav_hunk('last') end, 'Last Hunk')
      map('n', '[H', function() gs.nav_hunk('first') end, 'First Hunk')

      -- Stage / reset
      map({ 'n', 'x' }, '<leader>ghs', ':Gitsigns stage_hunk<CR>', 'Stage Hunk')
      map({ 'n', 'x' }, '<leader>ghr', ':Gitsigns reset_hunk<CR>', 'Reset Hunk')
      map('n', '<leader>ghS', gs.stage_buffer, 'Stage Buffer')
      map('n', '<leader>ghu', gs.undo_stage_hunk, 'Undo Stage Hunk')
      map('n', '<leader>ghR', gs.reset_buffer, 'Reset Buffer')
      map('n', '<leader>ghp', gs.preview_hunk_inline, 'Preview Hunk Inline')

      -- Blame
      map('n', '<leader>gb', function() gs.blame_line({ full = true }) end, 'Blame Line')
      map('n', '<leader>gB', function() gs.blame() end, 'Blame Buffer')

      -- Diff
      map('n', '<leader>gd', gs.diffthis, 'Diff This')
      map('n', '<leader>gD', function() gs.diffthis('~') end, 'Diff This ~')

      -- Text object
      map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'GitSigns Select Hunk')
    end,
  },
}
