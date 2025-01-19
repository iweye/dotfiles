local opts = { noremap = true, silent = true }

-- Basic
vim.keymap.set('i', 'jj', '<Esc>', opts)
vim.keymap.set('n', '<A-n>', ':nohlsearch<CR>', opts)

-- Copy to system clipboard
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y', opts)
vim.keymap.set({'n', 'v'}, '<leader><S-y>', '"+y$', opts)
-- Paste from system clipboard
vim.keymap.set({'n', 'v'}, '<leader>p', '"+p', opts)
vim.keymap.set({'n', 'v'}, '<leader>P', '"+P', opts)
-- Select all file
vim.keymap.set('n', '<leader>sa', 'ggVG', { silent = true })

-- Keep the selection after `y` in visual mode
-- vim.keymap.set('x', 'y', 'ygv', opts)

-- Comments
require('mini.comment').setup({
  mappings = {
    comment = '<C-/>',
    comment_line = '<C-/>',
    comment_visual = '<C-/>',
    textobject = '<C-/>'
  }
})

-- NeoTree
vim.keymap.set('n', '<leader>e', ':Neotree float reveal<CR>', opts)
vim.keymap.set('n', '<C-e>', ':Neotree focus left<CR>', opts)

-- Bufferline
vim.keymap.set('n', '<A-l>', ':BufferLineCycleNext<CR>', opts)
vim.keymap.set('n', '<A-h>', ':BufferLineCyclePrev<CR>', opts)
vim.keymap.set('n', '<C-l>', ':BufferLineMoveNext<CR>', opts)
vim.keymap.set('n', '<C-h>', ':BufferLineMovePrev<CR>', opts)
vim.keymap.set('n', '<A-o>', ':BufferLinePick<CR>', opts)
vim.keymap.set('n', '<A-t>', ':tabnew<CR>', opts)
vim.keymap.set('n', '<A-w>', ':bd<CR>', opts)

-- Hop
vim.keymap.set('n', '<leader>h', ':HopWord<CR>', opts)

-- CMP
local cmp = require('cmp')
cmp.setup({
  mapping = {
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' })
  }
})

-- LuaSnip
local ls = require('luasnip')

vim.keymap.set({'i'}, '<C-K>', function() ls.expand() end, {silent = true})
vim.keymap.set({'i', 's'}, '<C-K>', function() ls.jump( 1) end, {silent = true})
vim.keymap.set({'i', 's'}, '<C-J>', function() ls.jump(-1) end, {silent = true})

vim.keymap.set({'i', 's'}, '<C-E>', function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end, {silent = true})

-- Lsp
vim.keymap.set('n', '<leader>lD', vim.diagnostic.open_float)
vim.keymap.set('n', '[', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>ld', vim.diagnostic.setloclist)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    local opts = { buffer = ev.buf }
    vim.keymap.set('n', '<leader>ld', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>li', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<leader>la', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>lR', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>lf',
      function() vim.lsp.buf.format { async = true } end, opts)
  end
})

-- Horizontal scroll
vim.keymap.set('n', '<S-ScrollWheelDown>', 'zl', opts)
vim.keymap.set('n', '<S-ScrollWheelUp>', 'zh', opts)
-- vim.keymap.set('n', '<C-L>', 'zl', opts)
-- vim.keymap.set('n', '<C-H>', 'zh', opts)

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
