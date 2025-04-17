-- Indent Settings
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.smartindent = true

-- Line Numbers
vim.opt.number = true
-- vim.opt.relativenumber = true

-- Mouse
vim.opt.mouse = 'a'
vim.opt.mousefocus = true

-- Use system clipboard
vim.opt.clipboard = 'unnamedplus'

-- Format
vim.g.formatoptions = 'qrn1'
vim.opt.showmode = false
vim.opt.updatetime = 1000 -- ms
vim.wo.signcolumn = 'yes'
vim.opt.scrolloff = 999

vim.opt.virtualedit = 'block'
vim.opt.undofile = true
vim.opt.shell = '/bin/fish' -- vim.opt.shell = '/bin/bash'
vim.opt.path:append('**')

--vim.opt.list = true
--vim.opt.listchars:append('space:•')

-- For themes
vim.opt.termguicolors = true

-- Shorter messages
vim.opt.shortmess:append('c')

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
-- vim.g.loaded_node_provider = 0
-- vim.g.loaded_python_provider = 0
-- vim.g.loaded_python3_provider = 0

-- Fillchars
vim.opt.fillchars = {
  vert = '│',
  fold = '⠀',
  eob = ' ',
  diff = '⣿',
  msgsep = '‾',
  foldopen = '▾',
  foldsep = '│',
  foldclose = '▸'
}

-- For spell checking
vim.opt.spell = true
vim.opt.spelllang = { "en_us" }

-- To avoid emphasizing the wrong words
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd([[
      highlight clear SpellBad
      highlight clear SpellCap
      highlight clear SpellRare
      highlight clear SpellLocal
    ]])
  end,
})

-- Turns off auto-comment continuation
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    vim.opt_local.comments = ""
  end
})

-- Wrap only in text files
vim.opt.wrap = false
vim.api.nvim_exec([[
  augroup WrapTextFiles
    autocmd!
    autocmd FileType text,markdown setlocal wrap
  augroup END
]], false)
vim.wo.linebreak = true
