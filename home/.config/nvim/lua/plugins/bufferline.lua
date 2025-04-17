return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  event = 'VeryLazy',
  config = function ()
    local opts = { noremap = true, silent = true }
    vim.keymap.set('n', '<A-l>', ':BufferLineCycleNext<CR>', opts)
    vim.keymap.set('n', '<A-h>', ':BufferLineCyclePrev<CR>', opts)
    vim.keymap.set('n', '<C-l>', ':BufferLineMoveNext<CR>', opts)
    vim.keymap.set('n', '<C-h>', ':BufferLineMovePrev<CR>', opts)
    vim.keymap.set('n', '<A-o>', ':BufferLinePick<CR>', opts)
    vim.keymap.set('n', '<A-t>', ':tabnew<CR>', opts)
    vim.keymap.set('n', '<A-w>', ':bd!<CR>', opts)
    local bufferline = require('bufferline')
    bufferline.setup {
      options = {
        mode = "buffers",
        -- style_preset = bufferline.style_preset.default,
        -- themable = true | false
        -- numbers = "none",
        indicator = {
          style = 'underline' -- 'icon' | 'underline' | 'none',
        },
        buffer_close_icon = '󰅖',
        modified_icon = '● ',
        close_icon = ' ',
        left_trunc_marker = ' ',
        right_trunc_marker = ' ',
        max_name_length = 16,
        max_prefix_length = 16, -- prefix used when a buffer is de-duplicated
        truncate_names = true, -- whether or not tab names should be truncated
        tab_size = 16,
        diagnostics = "nvim_lsp", -- false | "nvim_lsp" | "coc",
        -- diagnostics_update_in_insert = false, -- only applies to coc
        -- diagnostics_update_on_event = true, -- use nvim's diagnostic handler
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
          return "("..count..")"
        end,
        custom_filter = function(buf_number)
          -- filter out filetypes you don't want to see
          if vim.bo[buf_number].filetype ~= "dashboard" then
            return true
          end
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            text_align = "center",
            separator = true
          }
        },
        color_icons = true,
        show_buffer_icons = true,
        show_buffer_close_icons = true,
        show_close_icon = false,
        show_tab_indicators = false,
        show_duplicate_prefix = false,
        duplicates_across_groups = false,
        persist_buffer_sort = false,
        move_wraps_at_ends = false,
        separator_style = "thin", -- "thick"
        enforce_regular_tabs = true,
        always_show_bufferline = true,
        auto_toggle_bufferline = true,
        sort_by = 'insert_after_current', -- |'insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs'
        pick = {
          alphabet = "abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMOPQRSTUVWXYZ1234567890",
        },
        custom_areas = {
          right = function()
            local result = {}
            local seve = vim.diagnostic.severity
            local error = #vim.diagnostic.get(0, {severity = seve.ERROR})
            local warning = #vim.diagnostic.get(0, {severity = seve.WARN})
            local info = #vim.diagnostic.get(0, {severity = seve.INFO})
            local hint = #vim.diagnostic.get(0, {severity = seve.HINT})

            if error ~= 0 then
              table.insert(result, {text = "  " .. error, link = "DiagnosticError"})
            end

            if warning ~= 0 then
              table.insert(result, {text = "  " .. warning, link = "DiagnosticWarn"})
            end

            if hint ~= 0 then
              table.insert(result, {text = "  " .. hint, link = "DiagnosticHint"})
            end

            if info ~= 0 then
              table.insert(result, {text = "  " .. info, link = "DiagnosticInfo"})
            end
            return result
          end,
        }
      }
    }
  end
}
