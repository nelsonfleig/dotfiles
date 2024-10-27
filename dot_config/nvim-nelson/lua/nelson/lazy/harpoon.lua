return {
    "theprimeagen/harpoon",
    config = function()
        local mark = require("harpoon.mark")
        local ui = require("harpoon.ui")

        vim.keymap.set("n", "<leader>ha", mark.add_file)                   -- Add file to Harpoon
        vim.keymap.set("n", "<leader>hh", ui.toggle_quick_menu)            -- Toggle Harpoon menu
        vim.keymap.set("n", "<leader>hn", ui.nav_next)                     -- Next Harpoon file
        vim.keymap.set("n", "<leader>hp", ui.nav_prev)                     -- Previous Harpoon file
        vim.keymap.set("n", "<leader>h1", function() ui.nav_file(1) end)   -- Go to Harpoon file 1
        vim.keymap.set("n", "<leader>h2", function() ui.nav_file(2) end)   -- Go to Harpoon file 2
        vim.keymap.set("n", "<leader>h3", function() ui.nav_file(3) end)   -- Go to Harpoon file 3
        vim.keymap.set("n", "<leader>h4", function() ui.nav_file(4) end)   -- Go to Harpoon file 4
    end
}
