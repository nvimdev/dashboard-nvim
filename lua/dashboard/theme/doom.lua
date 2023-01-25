local api = vim.api
local utils = require('dashboard.utils')

local function generate_center(config)
  local lines = {}
  for _, item in
    pairs(config.center or {
      { desc = 'Please config your own center section', key = 'p' },
    })
  do
    table.insert(lines, item.desc)
    table.insert(lines, '')
    if item.key then
      vim.keymap.set('n', item.key, function()
        vim.cmd(item.action)
      end, { buffer = config.bufnr, nowait = true, silent = true })
    end
  end
  lines = utils.element_align(lines)
  lines = utils.center_align(lines)

  local first_line = api.nvim_buf_line_count(config.bufnr)
  api.nvim_buf_set_lines(config.bufnr, first_line, -1, false, lines)

  local ns = api.nvim_create_namespace('DashboardDoom')
  local seed = 1
  for i = 1, #lines do
    if lines[i]:find('%w') then
      local idx = i == 1 and i or i - seed
      seed = seed + 1
      api.nvim_buf_add_highlight(config.bufnr, 0, 'DashboardCenter', first_line + i - 1, 0, -1)

      api.nvim_buf_set_extmark(config.bufnr, ns, first_line + i - 1, 0, {
        virt_text_pos = 'eol',
        virt_text = { { config.center[idx].key, 'Title' } },
      })
    end
  end

  local line = api.nvim_buf_get_lines(config.bufnr, first_line, first_line + 1, false)[1]
  local col = line:find('%w')
  api.nvim_win_set_cursor(config.winid, { first_line + 1, col - 1 })
end

local function generate_footer(config)
  local first_line = api.nvim_buf_line_count(config.bufnr)
  local footer = config.footer
    or { '', '', 'neovim loaded ' .. utils.get_packages_count() .. ' packages' }
  api.nvim_buf_set_lines(config.bufnr, first_line, -1, false, utils.center_align(footer))
  for i = 1, #footer do
    api.nvim_buf_add_highlight(config.bufnr, 0, 'DashboardFooter', first_line + i - 1, 0, -1)
  end
end

---@private
local function theme_instance(config)
  utils.generate_header(config)
  generate_center(config)
  generate_footer(config)
end

return setmetatable({}, {
  __call = function(_, t)
    return theme_instance(t)
  end,
})
