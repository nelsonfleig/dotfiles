return {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        local telescope = require('telescope')
        local actions = require('telescope.actions')
        telescope.setup({
            defaults = {
                path_display = { "smart" },
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous, -- move to prev result
                        ["<C-j>"] = actions.move_selection_next, -- move to next result
                        ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist
                    }
                }
            }
        })
        local builtin = require("telescope.builtin")

        -- Basic file and symbol searches
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})                 -- Find in git files
        vim.keymap.set("n", "<leader>ff", builtin.find_files, {})           -- Find files
        vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})            -- Live grep
        vim.keymap.set("n", "<leader>fb", builtin.buffers, {})              -- List buffers
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})            -- Help tags
        vim.keymap.set("n", "<leader>fc", builtin.commands, {})             -- List available commands
        vim.keymap.set("n", "<leader>fo", builtin.oldfiles, {})             -- Search files previously openned
        vim.keymap.set('n', '<leader>fw', builtin.grep_string, {})          -- Find word under cursor

        -- LSP-related searches
        vim.keymap.set("n", "<leader>fd", builtin.diagnostics, {})           -- List diagnostics
        vim.keymap.set("n", "<leader>fr", builtin.lsp_references, {})        -- List references
        vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, {})  -- List symbols in document
    end
}
