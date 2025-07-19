local M = {}

function M.setup()
  vim.opt.cmdheight = 0  -- сховати командну стрічку за замовчуванням

  vim.api.nvim_create_autocmd("CmdlineEnter", {
    callback = function()
      vim.opt.cmdheight = 1
    end,
  })

  vim.api.nvim_create_autocmd("CmdlineLeave", {
    callback = function()
      vim.opt.cmdheight = 0
    end,
  })
end

return M
