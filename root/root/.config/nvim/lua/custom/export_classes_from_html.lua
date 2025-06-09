local M = {}

M.export = function()
  local file_path = vim.api.nvim_buf_get_name(0)
  local classes = {}
  local seen_classes = {}

  local file = io.open(file_path, "r")

  for line in file:lines() do
    for class in line:gmatch('class%s*=%s*["\']([^"\']+)["\']') do
      for cls in class:gmatch("%S+") do
        if not seen_classes[cls] then
          table.insert(classes, "." .. cls .. " {}")
          seen_classes[cls] = true
        end
      end
    end
  end
  file:close()

  local result = table.concat(classes, "\n")
  os.execute("echo '" .. result .. "' | xclip -selection clipboard")
end

return M
