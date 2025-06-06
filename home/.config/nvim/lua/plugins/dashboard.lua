return {
  'nvimdev/dashboard-nvim',
  event = 'VimEnter',
  dependencies = { 'nvim-tree/nvim-web-devicons', event = 'VeryLazy' },
  config = function()
    local function default_header()
      return {
        '', '', '',
        '██ ██     ██ ███████ ██    ██ ███████',
        '██ ██     ██ ██       ██  ██  ██     ',
        '██ ██  █  ██ █████     ████   █████  ',
        '██ ██ ███ ██ ██         ██    ██     ',
        '██  ███ ███  ███████    ██    ███████',
        '', '', ''
      }
    end

    require('dashboard').setup {
      theme = 'doom',
      config = {
        header = default_header(),
        center = {
          {
            icon = '󰙅 ',
            icon_hl = 'Title',
            desc = 'Open tree',
            desc_hl = 'String',
            key = 'e',
            keymap = 'SPC e',
            key_hl = 'Number',
            action = ':Yazi toggle'
          },
          {
            icon = '󰈞 ',
            icon_hl = 'Title',
            desc = 'Find files',
            desc_hl = 'String',
            key = 'f',
            keymap = 'SPC f f',
            key_hl = 'Number',
            action = ':Telescope find_files'
          },
          {
            icon = ' ',
            icon_hl = 'Title',
            desc = 'Find text',
            desc_hl = 'String',
            key = 'g',
            keymap = 'SPC f g',
            key_hl = 'Number',
            action = ':Telescope live_grep'
          },
          {
            icon = ' ',
            icon_hl = 'Title',
            desc = 'Git Braches',
            desc_hl = 'String',
            key = 'b',
            keymap = 'SPC g b',
            key_hl = 'Number',
            action = ':Telescope git_branches'
          }
        }
      }
    }
  end
}
