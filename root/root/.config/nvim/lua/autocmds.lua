require "nvchad.autocmds"

-- Dynamic terminal padding

local autocmd = vim.api.nvim_create_autocmd

autocmd("VimEnter", {
  command = ":silent !kitty @ set-spacing padding=0 margin=0",
})

autocmd("VimLeavePre", {
  command = ":silent !kitty @ set-spacing padding=20 margin=10",
})

-- Restore cursor position

autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line "'\""
    if
      line > 1
      and line <= vim.fn.line "$"
      and vim.bo.filetype ~= "commit"
      and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
    then
      vim.cmd 'normal! g`"'
    end
  end,
})

-- Show Nvdash when all buffers are closed

autocmd("BufDelete", {
  callback = function()
    local bufs = vim.t.bufs
    if #bufs == 1 and vim.api.nvim_buf_get_name(bufs[1]) == "" then
      vim.cmd "Nvdash"
    end
  end,
})

-- Show Nvdash when open without file

autocmd("VimEnter", {
  callback = function()
    -- якщо немає відкритих буферів або відкритий тільки порожній буфер
    if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == "" then
      vim.cmd("Nvdash")
    end
  end,
})

-- Auto hide command line

vim.opt.cmdheight = 0  -- сховати командну стрічку за замовчуванням

autocmd("CmdlineEnter", {
  callback = function()
    vim.opt.cmdheight = 1
  end,
})

autocmd("CmdlineLeave", {
  callback = function()
    vim.opt.cmdheight = 0
  end,
})
