local opts = { noremap = true, silent = true }

-- Basic
vim.keymap.set('i', 'jj', '<Esc>', opts)
vim.keymap.set('n', '<A-n>', ':nohlsearch<CR>', opts)

-- Copy and save selection
vim.keymap.set({'n', 'v'}, '<S-y>', 'ygv', opts)
-- Select all file
vim.keymap.set('n', '<C-a>', 'ggVG', opts)
-- Change word without copy
vim.keymap.set("n", "cw", '"_cw', { noremap = true })
-- Delete symbol without copy
vim.keymap.set("n", "x", '"_x', { noremap = true })

-- Save
vim.keymap.set('n', '<C-s>', ':w!<CR>', opts)

-- Horizontal scroll
vim.keymap.set('n', '<S-ScrollWheelDown>', 'zl', opts)
vim.keymap.set('n', '<S-ScrollWheelUp>', 'zh', opts)

local export_classes_from_html = require("scripts.export_classes_from_html")
vim.keymap.set('n', '<leader>pp', export_classes_from_html.export, opts)

-- Telescope
-- local builtin = require('telescope.builtin')
-- vim.keymap.set('n', '<leader>ff', builtin.find_files)
-- vim.keymap.set('n', '<leader>fg', builtin.live_grep)
-- vim.keymap.set('n', '<leader>fb', builtin.buffers)
-- vim.keymap.set('n', '<leader>fh', builtin.help_tags)
-- vim.keymap.set('n', '<leader>gb', builtin.git_branches)
-- vim.keymap.set('n', '<leader>gc', builtin.git_commits)
-- vim.keymap.set('n', '<leader>gs', builtin.git_status)
-- vim.keymap.set('n', '<leader>fr', builtin.lsp_references, opts)
-- vim.keymap.set('n', '<leader>fd', builtin.lsp_definitions, opts)
