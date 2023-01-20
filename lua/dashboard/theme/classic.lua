local api = vim.api
local utils = require('dashboard.utils')

local function generate_center(config, elements)
  config = config or {}

  if vim.tbl_isempty(config) then
    config = {
      { desc = 'Please config your own center section' },
    }
  end
  local first_line = #elements.lines + 1

  vim.tbl_map(function(k)
    if not k.desc then
      vim.notify('[Dashboard.nvim] Missing desc keyword in center')
      return
    end
    vim.list_extend(elements.lines, utils.center_align({ k.desc }))
  end, config)

  local center_fn = function(bufnr, _)
    for i, item in pairs(config) do
      api.nvim_buf_add_highlight(bufnr, 0, 'DashboardCenter', first_line + i - 2, 0, -1)
      if item.keymap then
        vim.keymap.set('n', item.keymap, function()
          vim.cmd(item.action)
        end, { buffer = bufnr, nowait = true, silent = true })
      end
    end
  end

  local set_cursor = function(bufnr, winid)
    local line = api.nvim_buf_get_lines(bufnr, first_line - 1, first_line, false)[1]
    local col = line:find('%w')
    api.nvim_win_set_cursor(winid, { first_line, col - 1 })
  end

  vim.list_extend(elements.fns, { center_fn, set_cursor })
end

local function generate_footer(footer, elements)
  footer = footer or { 'neovim loaded ' .. utils.get_packages_count() .. ' packages' }
  footer = utils.center_align(footer)
  local first_line = #elements.lines
  vim.list_extend(elements.lines, footer)
  local footer_highlight = function(bufnr, _)
    for i, _ in pairs(footer) do
      api.nvim_buf_add_highlight(bufnr, 0, 'DashboardFooter', first_line + i - 1, 0, -1)
    end
  end
  table.insert(elements.fns, footer_highlight)
end

---@private
local function theme_instance(opts)
  local elements = {
    lines = {},
    fns = {},
  }
  utils.generate_header(opts.header, elements)
  generate_center(opts.center, elements)
  generate_footer(opts.footer, elements)
  return elements
end

return setmetatable({}, {
  __call = function(_, t)
    return theme_instance(t)
  end,
})
