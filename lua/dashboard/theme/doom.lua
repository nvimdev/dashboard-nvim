local api = vim.api
local utils = require('dashboard.utils')

local function generate_center(config)
  local lines = {}
  for _, item in
    pairs(config.center or {
      { desc = 'Please config your own center section', key = 'p' },
    })
  do
    table.insert(lines, item.icon and item.icon .. item.desc or item.desc)
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
    local scol = lines[i]:find('%w')
    if scol then
      local idx = i == 1 and i or i - seed
      seed = seed + 1
      api.nvim_buf_add_highlight(
        config.bufnr,
        0,
        config.center[idx].desc_hi or 'Number',
        first_line + i - 1,
        scol - 1,
        -1
      )

      if config.center[idx].icon then
        print(idx, config.center[idx].icon_hi)
        api.nvim_buf_add_highlight(
          config.bufnr,
          0,
          config.center[idx].icon_hi or 'String',
          first_line + i - 1,
          0,
          scol - 1
        )
      end

      if config.center[idx].key then
        api.nvim_buf_set_extmark(config.bufnr, ns, first_line + i - 1, 0, {
          virt_text_pos = 'eol',
          virt_text = { { config.center[idx].key, config.center[idx].key_hi or 'Title' } },
        })
      end
    end
  end

  local line = api.nvim_buf_get_lines(config.bufnr, first_line, first_line + 1, false)[1]
  local col = line:find('%w')
  api.nvim_win_set_cursor(config.winid, { first_line + 1, col - 1 })

  local bottom = api.nvim_buf_line_count(config.bufnr)
  vim.defer_fn(function()
    local before = 0
    api.nvim_create_autocmd('CursorMoved', {
      buffer = config.bufnr,
      callback = function()
        local curline = api.nvim_win_get_cursor(0)[1]
        if curline < first_line + 1 then
          curline = bottom - 1
        elseif curline > bottom - 1 then
          curline = first_line + 1
        elseif not api.nvim_get_current_line():find('%w') then
          curline = curline + (before > curline and -1 or 1)
        end
        before = curline
        api.nvim_win_set_cursor(config.winid, { curline, col - 1 })
      end,
    })
  end, 0)
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
