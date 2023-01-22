local api = vim.api
local utils = require('dashboard.utils')

local function generate_center(config)
  local center = vim.tbl_extend('force', {
    { desc = 'Please config your own center section' },
  }, config.center or {})

  local lines = {}
  for _, item in pairs(center) do
    table.insert(lines, item.desc)
    if item.keymap then
      vim.keymap.set('n', item.keymap, function()
        vim.cmd(item.action)
      end, { buffer = config.bufnr, nowait = true, silent = true })
    end
  end
  lines = utils.center_align(lines)

  local first_line = api.nvim_buf_line_count(config.bufnr)
  api.nvim_buf_set_lines(config.bufnr, first_line, -1, false, lines)

  for i = 1, #lines do
    api.nvim_buf_add_highlight(config.bufnr, 0, 'DashboardCenter', first_line + i - 2, 0, -1)
  end

  local line = api.nvim_buf_get_lines(config.bufnr, first_line, first_line + 1, false)[1]
  local col = line:find('%w')
  api.nvim_win_set_cursor(config.winid, { first_line + 1, col - 1 })
end

local function generate_footer(config)
  local first_line = api.nvim_buf_line_count(config.bufnr)
  local footer = config.footer or { 'neovim loaded ' .. utils.get_packages_count() .. ' packages' }
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
