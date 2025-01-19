local M = {}

-- Шлях до файлу для збереження останньої теми
local theme_file = vim.fn.stdpath("config") .. "/last_colorscheme"

-- Функція для збереження теми
local function save_colorscheme(scheme)
  local file = io.open(theme_file, "w")
  if file then
    file:write(scheme)
    file:close()
  end
end

-- Спроба завантажити останню тему
local function load_last_colorscheme()
  local file = io.open(theme_file, "r")
  if file then
    local scheme = file:read("*l")
    file:close()
    if scheme and pcall(vim.cmd, "colorscheme " .. scheme) then
      return
    end
  end
  print("Не вдалося завантажити останню тему. Використовується стандартна.")
end

-- Автокоманда для збереження теми при її зміні
local function setup_autosave()
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      local scheme = vim.api.nvim_exec("echo g:colors_name", true)
      if scheme and scheme ~= "" then
        save_colorscheme(scheme)
      end
    end,
  })
end

-- Основна функція setup
function M.setup()
  load_last_colorscheme()
  setup_autosave()
end

return M
