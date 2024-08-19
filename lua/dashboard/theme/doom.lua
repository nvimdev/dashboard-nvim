local api, keymap = vim.api, vim.keymap
local utils = require('dashboard.utils')

local vert_offset

local function gen_center_icons_and_descriptions(config)
  local lines = {}
  local center = config.center

  local counts = {}
  for _, item in pairs(center) do
    local count = item.keymap and #item.keymap or 0
    local line = (item.icon or '') .. item.desc

    if item.key then
      line = line .. (' '):rep(#item.key + 4)
      count = count + #item.key + 3
      local desc = 'Dashboard-action: ' .. item.desc:gsub('^%s+', '')
      keymap.set('n', item.key, function()
        if type(item.action) == 'string' then
          local dump = loadstring(item.action)
          if not dump then
            vim.cmd(item.action)
          else
            dump()
          end
        elseif type(item.action) == 'function' then
          item.action()
        end
      end, { buffer = config.bufnr, nowait = true, silent = true, desc = desc })
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

  api.nvim_buf_set_lines(config.bufnr, vert_offset, -1, false, lines)
  return lines
end

local function gen_center_highlights_and_keys(config, lines)
  local ns = api.nvim_create_namespace('DashboardDoom')
  local seed = 0
  local position_map = {}
  for i = 1, #lines do
    if lines[i]:find('%w') then
      local idx = i == 1 and i or i - seed
      seed = seed + 1
      position_map[i] = idx
      local _, scol = lines[i]:find('%s+')
      local ecol = scol + (config.center[idx].icon and #config.center[idx].icon or 0)

      if config.center[idx].icon then
        api.nvim_buf_add_highlight(
          config.bufnr,
          0,
          config.center[idx].icon_hl or 'DashboardIcon',
          vert_offset + i - 1,
          0,
          ecol
        )
      end

      api.nvim_buf_add_highlight(
        config.bufnr,
        0,
        config.center[idx].desc_hl or 'DashboardDesc',
        vert_offset + i - 1,
        ecol,
        -1
      )

      if config.center[idx].key then
        local virt_tbl = {}
        if config.center[idx].keymap then
          table.insert(virt_tbl, { config.center[idx].keymap, 'DashboardShortCut' })
        end
        table.insert(virt_tbl, {
          string.format(config.center[idx].key_format or ' [%s]', config.center[idx].key),
          config.center[idx].key_hl or 'DashboardKey',
        })
        api.nvim_buf_set_extmark(config.bufnr, ns, vert_offset + i - 1, 0, {
          virt_text_pos = 'eol',
          virt_text = virt_tbl,
        })
      end
    end
  end
  return position_map
end

local function gen_center_base(config)
  if not config.center then
    local msg = utils.center_align({ 'Please config your own center section', '' })
    api.nvim_buf_set_lines(config.bufnr, vert_offset, -1, false, msg)
    return {}
  end

  local lines = gen_center_icons_and_descriptions(config)
  return lines
end

local function move_cursor_behaviour(config, bottom_linenr)
  local line = api.nvim_buf_get_lines(config.bufnr, vert_offset, vert_offset + 1, false)[1]
  local col = line:find('%w')
  local col_width = api.nvim_strwidth(line:sub(1, col))
  col = col and col - 1 or 9999
  api.nvim_win_set_cursor(config.winid, { vert_offset + 1, col })

  vim.defer_fn(function()
    local before = 0
    if api.nvim_get_current_buf() ~= config.bufnr then
      return
    end

    local dashboard_group = api.nvim_create_augroup('DashboardDoomCursor', { clear = true })
    api.nvim_create_autocmd('CursorMoved', {
      buffer = config.bufnr,
      group = dashboard_group,
      callback = function()
        local buf = api.nvim_win_get_buf(0)
        if vim.api.nvim_get_option_value('filetype', { buf = buf }) ~= 'dashboard' then
          return
        end

        local curline = api.nvim_win_get_cursor(0)[1]
        if curline < vert_offset + 1 then
          curline = bottom_linenr - 1
        elseif curline > bottom_linenr - 1 then
          curline = vert_offset + 1
        elseif not api.nvim_get_current_line():find('%w') then
          curline = curline + (before > curline and -1 or 1)
        end
        before = curline

        -- NOTE: #422: In Lua the length of a string is the number of bytes not
        -- the number of characters.
        local curline_str = api.nvim_buf_get_lines(config.bufnr, curline - 1, curline, false)[1]
        local strwidth = api.nvim_strwidth(curline_str:sub(1, col + 1))
        local col_with_offset = col + col_width - strwidth
        if col_with_offset < 0 then
          col_with_offset = 0
        end
        api.nvim_win_set_cursor(config.winid, { curline, col_with_offset })
      end,
    })
  end, 0)
end

local function confirm_key(config, position_map)
  keymap.set('n', config.confirm_key or '<CR>', function()
    local curline = api.nvim_win_get_cursor(0)[1]
    local index = position_map[curline - vert_offset]
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

local function load_packages(config)
  local packages = config.packages or {
    enable = true,
  }
  if not packages.enable then
    return
  end

  local package_manager_stats = utils.get_package_manager_stats()
  local lines = {}
  if package_manager_stats.name == 'lazy' then
    lines = {
      '',
      'Startuptime: ' .. package_manager_stats.time .. ' ms',
      'Plugins: '
        .. package_manager_stats.loaded
        .. ' loaded / '
        .. package_manager_stats.count
        .. ' installed',
    }
  else
    lines = {
      '',
      'neovim loaded ' .. package_manager_stats.count .. ' plugins',
    }
  end

  local first_line = api.nvim_buf_line_count(config.bufnr)
  api.nvim_buf_set_lines(config.bufnr, first_line, -1, false, utils.center_align(lines))

  for i, _ in pairs(lines) do
    api.nvim_buf_add_highlight(config.bufnr, 0, 'Comment', first_line + i - 1, 0, -1)
  end

  return lines
end

local function gen_footer(config)
  local lines = {} ---@type table?
  if config.footer then
    if type(config.footer) == 'function' then
      lines = config.footer()
    elseif type(config.footer) == 'string' then
      local dump = loadstring(config.footer)
      if dump then
        lines = dump()
      end
    elseif type(config.footer) == 'table' then
      lines = config.footer
    end
    local first_line = api.nvim_buf_line_count(config.bufnr)
    api.nvim_buf_set_lines(config.bufnr, first_line, -1, false, utils.center_align(lines))
    for i = 1, #lines do
      api.nvim_buf_add_highlight(config.bufnr, 0, 'DashboardFooter', first_line + i - 1, 0, -1)
    end
  else
    lines = load_packages(config)
  end
  utils.add_update_footer_command(config.bufnr, lines)
  return #lines
end

local function vertical_center(config)
  if config.vertical_center ~= true then
    return
  end

  local size = math.floor(vim.o.lines / 2)
    - math.ceil(api.nvim_buf_line_count(config.bufnr) / 2)
    - 2
  local fill = utils.generate_empty_table(size)
  api.nvim_buf_set_lines(config.bufnr, 0, 0, false, fill)

  vert_offset = vert_offset + (size < 0 and 0 or size)
end

local function theme_instance(config)
  require('dashboard.theme.header').generate_header(config)
  vert_offset = api.nvim_buf_line_count(config.bufnr)

  local lines = gen_center_base(config)
  local footer_size = gen_footer(config)
  vertical_center(config)
  local actions_position_map = gen_center_highlights_and_keys(config, lines)

  local last_entry_pos = api.nvim_buf_line_count(config.bufnr) - footer_size
  move_cursor_behaviour(config, last_entry_pos)
  confirm_key(config, actions_position_map)

  vim.bo[config.bufnr].modifiable = false
  vim.bo[config.bufnr].modified = false
  -- defer until next event loop
  vim.schedule(function()
    api.nvim_exec_autocmds('User', {
      pattern = 'DashboardLoaded',
      modeline = false,
    })
  end)
end

return setmetatable({}, {
  __call = function(_, t)
    return theme_instance(t)
  end,
})
