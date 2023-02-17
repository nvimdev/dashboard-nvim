local api = vim.api
local utils = require('dashboard.utils')

local function generate_center(config)
  local lines = {}
  local center = config.center
    or {
      { desc = 'Please config your own center section', key = 'p' },
    }

  local counts = {}
  for _, item in pairs(center) do
    local count = item.keymap and #item.keymap or 0
    local line = (item.icon or '') .. item.desc

    if item.key then
      line = line .. (' '):rep(#item.key + 4)
      count = count + #item.key + 3
      if type(item.action) == 'string' then
        vim.keymap.set('n', item.key, function()
          local dump = loadstring(item.action)
          if not dump then
            vim.cmd(item.action)
          else
            dump()
          end
        end, { buffer = config.bufnr, nowait = true, silent = true })
      elseif type(item.action) == 'function' then
        vim.keymap.set(
          'n',
          item.key,
          item.action,
          { buffer = config.bufnr, nowait = true, silent = true }
        )
      end
    end

    if item.keymap then
      line = line .. (' '):rep(#item.keymap)
    end

    table.insert(lines, line)
    table.insert(lines, '')
    table.insert(counts, count)
    table.insert(counts, 0)
  end

  lines = utils.element_align(lines)
  lines = utils.center_align(lines)
  for i, count in ipairs(counts) do
    lines[i] = lines[i]:sub(1, #lines[i] - count)
  end

  table.remove(lines, #lines)

  local first_line = api.nvim_buf_line_count(config.bufnr)
  api.nvim_buf_set_lines(config.bufnr, first_line, -1, false, lines)

  if not config.center then
    return
  end

  local ns = api.nvim_create_namespace('DashboardDoom')
  local seed = 0
  local pos_map = {}
  for i = 1, #lines do
    if lines[i]:find('%w') then
      local idx = i == 1 and i or i - seed
      seed = seed + 1
      pos_map[i] = idx
      local _, scol = lines[i]:find('%s+')
      local ecol = scol + (config.center[idx].icon and #config.center[idx].icon or 0)

      if config.center[idx].icon then
        api.nvim_buf_add_highlight(
          config.bufnr,
          0,
          config.center[idx].icon_hl or 'DashboardIcon',
          first_line + i - 1,
          0,
          ecol
        )
      end

      api.nvim_buf_add_highlight(
        config.bufnr,
        0,
        config.center[idx].desc_hl or 'DashboardDesc',
        first_line + i - 1,
        ecol,
        -1
      )

      if config.center[idx].key then
        local virt_tbl = {}
        if config.center[idx].keymap then
          table.insert(virt_tbl, { config.center[idx].keymap, 'DashboardShortCut' })
        end
        table.insert(
          virt_tbl,
          { ' [' .. config.center[idx].key .. ']', config.center[idx].key_hl or 'DashboardKey' }
        )
        api.nvim_buf_set_extmark(config.bufnr, ns, first_line + i - 1, 0, {
          virt_text_pos = 'eol',
          virt_text = virt_tbl,
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

  vim.keymap.set('n', config.confirm_key or '<CR>', function()
    local curline = api.nvim_win_get_cursor(0)[1]
    local index = pos_map[curline - first_line]
    if index and config.center[index].action then
      if type(config.center[index].action) == 'string' then
        local dump = loadstring(config.center[index].action)
        if not dump then
          vim.cmd(config.center[index].action)
        else
          dump()
        end
      elseif type(config.center[index].action) == 'function' then
        config.center[index].action()
      else
        print('Error with action, check your config')
      end
    end
  end, { buffer = config.bufnr, nowait = true, silent = true })
end

local function init_footer(config, from_cache)
  local top_padding = config.footer_top_padding or 1
  if not config.footer then
    config.footer = { 'neovim loaded ' .. utils.get_packages_count() .. ' packages' }
    utils.pad(config.footer, '', top_padding, true)
    return
  end
  if type(config.footer) == 'function' then
    config.footer = config.footer()
    utils.pad(config.footer, '', top_padding, true)
    return
  end
  if not from_cache then
    utils.pad(config.footer, '', top_padding, true)
  end
end

local function generate_footer(config)
  local first_line = api.nvim_buf_line_count(config.bufnr)
  api.nvim_buf_set_lines(config.bufnr, first_line, -1, false, utils.center_align(footer))
  for i = 1, #footer do
    api.nvim_buf_add_highlight(config.bufnr, 0, 'DashboardFooter', first_line + i - 1, 0, -1)
  end
end

---@private
local function theme_instance(config)
  require('dashboard.theme.header').generate_header(config)
  generate_center(config)
  generate_footer(config)
  local size = utils.calc_top_padding(config)
  local fill = utils.generate_empty_table(size)
  api.nvim_buf_set_lines(config.bufnr, 0, 0, false, fill)
  vim.bo[config.bufnr].modifiable = false
end

local function init(config, from_cache)
    init_footer(config, from_cache)
    require('dashboard.theme.header').init_header(config, from_cache)
end

return setmetatable({}, {
  __call = function(_, config, from_cache)
    init(config, from_cache)
    theme_instance(config)
  end,
})
