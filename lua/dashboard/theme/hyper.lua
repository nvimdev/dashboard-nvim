local api, keymap, uv = vim.api, vim.keymap, vim.loop
local utils = require('dashboard.utils')
local ns = api.nvim_create_namespace('dashboard')

local function gen_shortcut(config)
  local shortcut = config.shortcut
    or {
      { desc = '[  Github]', group = 'DashboardShortCut' },
      { desc = '[  glepnir]', group = 'DashboardShortCut' },
      { desc = '[  0.2.3]', group = 'DashboardShortCut' },
    }

  if vim.tbl_isempty(shortcut) then
    shortcut = {}
  end

  local lines = ''
  for _, item in pairs(shortcut) do
    local str = item.icon and item.icon .. item.desc or item.desc
    if item.key then
      str = str .. '[' .. item.key .. ']'
    end
    lines = lines .. '  ' .. str
  end

  local first_line = api.nvim_buf_line_count(config.bufnr)
  api.nvim_buf_set_lines(config.bufnr, first_line, -1, false, utils.center_align({ lines }))

  local line = api.nvim_buf_get_lines(config.bufnr, first_line, -1, false)[1]
  local start = line:find('[^%s]') - 1
  for _, item in pairs(shortcut) do
    local _end = start + (item.icon and #(item.icon .. item.desc) or #item.desc)
    if item.key then
      _end = _end + api.nvim_strwidth(item.key) + 2
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
      end, { buffer = config.bufnr, nowait = true, silent = true })
    end

    api.nvim_buf_add_highlight(
      config.bufnr,
      0,
      item.group or 'DashboardShortCut',
      first_line,
      start,
      _end
    )

    if item.icon then
      api.nvim_buf_add_highlight(
        config.bufnr,
        0,
        item.icon_hl or 'DashboardShortCutIcon',
        first_line,
        start,
        start + #item.icon
      )
    end
    start = _end + 2
  end
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
end

local function reverse(tbl)
  for i = 1, math.floor(#tbl / 2) do
    tbl[i], tbl[#tbl - i + 1] = tbl[#tbl - i + 1], tbl[i]
  end
end

local function project_list(config, callback)
  config.project = vim.tbl_extend('force', {
    limit = 8,
    enable = true,
    icon = '󰏓 ',
    icon_hl = 'DashboardRecentProjectIcon',
    action = 'Telescope find_files cwd=',
    label = ' Recent Projects:',
  }, config.project or {})

  local function read_project(data)
    local res = {}
    data = string.gsub(data, '%z', '')
    local dump = assert(loadstring(data))
    local list = dump()
    if list then
      list = vim.list_slice(list, #list - config.project.limit)
    end
    for _, dir in ipairs(list or {}) do
      dir = dir:gsub(vim.env.HOME, '~')
      table.insert(res, (' '):rep(3) .. ' ' .. dir)
    end

    if #res == 0 then
      table.insert(res, (' '):rep(3) .. ' empty project')
    else
      reverse(res)
    end

    table.insert(res, 1, config.project.icon .. config.project.label)
    table.insert(res, 1, '')
    table.insert(res, '')
    return res
  end

  utils.async_read(
    config.path,
    vim.schedule_wrap(function(data)
      local res = {}
      if config.project.enable then
        res = read_project(data)
      end
      callback(res)
    end)
  )
end

local function mru_list(config)
  config.mru = vim.tbl_extend('force', {
    icon = ' ',
    limit = 10,
    icon_hl = 'DashboardMruIcon',
    label = ' Most Recent Files:',
    cwd_only = false,
    enable = true,
  }, config.mru or {})

  if not config.mru.enable then
    return {}, {}
  end

  local list = {
    config.mru.icon .. config.mru.label,
  }

  local groups = {}
  local mlist = utils.get_mru_list()

  if config.mru.cwd_only then
    local cwd = uv.cwd()
    -- get separator from the first file
    local sep = mlist[1]:match('[\\/]')
    local cwd_with_sep = cwd:gsub('[\\/]', sep) .. sep
    mlist = vim.tbl_filter(function(file)
      local file_dir = vim.fn.fnamemodify(file, ':p:h')
      if file_dir and cwd_with_sep then
        return file_dir:sub(1, #cwd_with_sep) == cwd_with_sep
      end
    end, mlist)
  end

  for _, file in pairs(vim.list_slice(mlist, 1, config.mru.limit)) do
    local filename = vim.fn.fnamemodify(file, ':t')
    local icon, group = utils.get_icon(filename)
    icon = icon or ''
    if config.mru.cwd_only then
      file = vim.fn.fnamemodify(file, ':.')
    elseif not utils.is_win then
      file = vim.fn.fnamemodify(file, ':~')
    end
    file = icon .. ' ' .. file
    table.insert(groups, { #icon, group })
    table.insert(list, (' '):rep(3) .. file)
  end

  if #list == 1 then
    table.insert(list, (' '):rep(3) .. ' empty files')
  end
  return list, groups
end

local function shuffle_table(table)
  for i = #table, 2, -1 do
    local j = math.random(i)
    table[i], table[j] = table[j], table[i]
  end
end

local function letter_hotkey(config)
  local used_keys = {}
  local shuffle = config.shuffle_letter
  local letter_list = config.letter_list

  for _, item in pairs(config.shortcut or {}) do
    if item.key then
      table.insert(used_keys, item.key:byte())
    end
  end

  math.randomseed(os.time())

  -- Create key table, fill it with unused characters.
  local function collect_unused_keys(uppercase)
    local unused_keys = {}
    for key in letter_list:gmatch('.') do
      if uppercase then
        key = key:upper()
      end
      key = key:byte()
      if not vim.tbl_contains(used_keys, key) then
        table.insert(unused_keys, key)
      end
    end
    if shuffle then
      shuffle_table(unused_keys)
    end
    return unused_keys
  end

  local unused_keys_lowercase = collect_unused_keys(false)
  local unused_keys_uppercase = collect_unused_keys(true)

  -- Push shuffled uppercase keys after the lowercase ones
  for _, key in pairs(unused_keys_uppercase) do
    table.insert(unused_keys_lowercase, key)
  end

  local fallback_hotkey = 0

  return function()
    if #unused_keys_lowercase ~= 0 then
      -- Pop an unused key to use it as a hotkey.
      local key = table.remove(unused_keys_lowercase, 1)
      return string.char(key)
    else
      -- All keys are already used. Fallback to the number generation.
      fallback_hotkey = fallback_hotkey + 1
      return fallback_hotkey
    end
  end
end

local function number_hotkey()
  local start = 0
  return function()
    start = start + 1
    return start
  end
end

local function gen_hotkey(config)
  if config.shortcut_type == 'number' then
    return number_hotkey()
  end
  return letter_hotkey(config)
end

local function map_key(config, key, content)
  keymap.set('n', key, function()
    local text = content or api.nvim_get_current_line()
    local scol = utils.is_win and text:find('%w') or text:find('%p')
    local path = nil

    if scol ~= nil then -- scol == nil if pressing enter in empty space
      if text:sub(scol, scol + 1) ~= '~/' then -- is relative path
        scol = math.min(text:find('%w'), text:find('%p'))
      end
      text = text:sub(scol)
      path = text:sub(1, text:find('%w(%s+)$'))
      path = vim.fs.normalize(path)
    end

    if path == nil then
      vim.cmd('enew')
    elseif vim.fn.isdirectory(path) == 1 then
      vim.cmd('lcd ' .. path)
      if type(config.project.action) == 'function' then
        config.project.action(path)
      elseif type(config.project.action) == 'string' then
        local dump = loadstring(config.project.action)
        if not dump then
          vim.cmd(config.project.action .. path)
        else
          dump(path)
        end
      end
    else
      vim.cmd('edit ' .. vim.fn.fnameescape(path))
      local root = utils.get_vcs_root()
      if not config.change_to_vcs_root then
        return
      end
      if #root > 0 then
        vim.cmd('lcd ' .. vim.fn.fnamemodify(root[#root], ':h'))
      else
        vim.cmd('lcd ' .. vim.fn.fnamemodify(path, ':h'))
      end
    end
  end, { buffer = config.bufnr, silent = true, nowait = true })
end

local function gen_center(plist, config)
  local mlist, mgroups = mru_list(config)
  local plist_len = #plist
  if plist_len == 0 then
    plist[#plist + 1] = ''
    plist_len = 1
  end
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.list_extend(plist, mlist)
  local max_len = utils.get_max_len(plist)
  if max_len <= 40 then
    local fill = (' '):rep(math.floor(vim.o.columns / 4))
    for i, v in pairs(plist) do
      plist[i] = v .. fill
    end
  end

  plist = utils.element_align(plist)
  plist = utils.center_align(plist)
  local first_line = api.nvim_buf_line_count(config.bufnr)
  api.nvim_buf_set_lines(config.bufnr, first_line, -1, false, plist)

  if not config.project.enable and not config.mru.enable then
    return
  end

  local _, scol = plist[2]:find('%S')
  if scol == nil then
    scol = 0
  end

  local start_col = scol
  if config.mru.enable then
    start_col = plist[plist_len + 2]:find('[^%s]') - 1
  end

  local hotkey = gen_hotkey(config)

  api.nvim_buf_add_highlight(config.bufnr, 0, 'DashboardProjectTitle', first_line + 1, 0, -1)
  api.nvim_buf_add_highlight(
    config.bufnr,
    0,
    'DashboardProjectTitleIcon',
    first_line + 1,
    0,
    scol + #config.project.icon
  )

  for i = 3, plist_len do
    api.nvim_buf_add_highlight(
      config.bufnr,
      0,
      'DashboardProjectIcon',
      first_line + i - 1,
      0,
      start_col + 3
    )
    api.nvim_buf_add_highlight(
      config.bufnr,
      0,
      'DashboardFiles',
      first_line + i - 1,
      start_col + 3,
      -1
    )
    local text = api.nvim_buf_get_lines(config.bufnr, first_line + i - 1, first_line + i, false)[1]
    if text and text:find('%w') and not text:find('empty') then
      local key = tostring(hotkey())
      api.nvim_buf_set_extmark(config.bufnr, ns, first_line + i - 1, 0, {
        virt_text = { { key, 'DashboardShortCut' } },
        virt_text_pos = 'eol',
      })
      map_key(config, key, text)
    end
  end

  -- initialize the cursor pos
  api.nvim_win_set_cursor(config.winid, { first_line + 3, start_col + 4 })

  api.nvim_buf_add_highlight(config.bufnr, 0, 'DashboardMruTitle', first_line + plist_len, 0, -1)
  api.nvim_buf_add_highlight(
    config.bufnr,
    0,
    'DashboardMruIcon',
    first_line + plist_len,
    0,
    scol + #config.mru.icon
  )

  for i, data in pairs(mgroups) do
    local len, group = unpack(data)
    if group then
      api.nvim_buf_add_highlight(
        config.bufnr,
        0,
        group,
        first_line + i + plist_len,
        start_col,
        start_col + len
      )
    end
    api.nvim_buf_add_highlight(
      config.bufnr,
      0,
      'DashboardFiles',
      first_line + i + plist_len,
      start_col + len,
      -1
    )

    local text = api.nvim_buf_get_lines(
      config.bufnr,
      first_line + i + plist_len,
      first_line + i + plist_len + 1,
      false
    )[1]
    if text and text:find('%w') then
      local key = tostring(hotkey())
      api.nvim_buf_set_extmark(config.bufnr, ns, first_line + i + plist_len, 0, {
        virt_text = { { key, 'DashboardShortCut' } },
        virt_text_pos = 'eol',
      })
      map_key(config, key, text)
    end
  end
end

local function gen_footer(config)
  local footer = {
    '',
    ' 🚀 Sharp tools make good work.',
  }

  if type(config.footer) == 'string' then
    local dump = loadstring(config.footer)
    if dump then
      footer = dump()
    end
  elseif type(config.footer) == 'function' then
    footer = config.footer()
  elseif type(config.footer) == 'table' then
    footer = config.footer
  end

  local first_line = api.nvim_buf_line_count(config.bufnr)
  api.nvim_buf_set_lines(config.bufnr, first_line, -1, false, utils.center_align(footer))

  ---@diagnostic disable-next-line: param-type-mismatch
  for i, _ in pairs(footer) do
    api.nvim_buf_add_highlight(config.bufnr, 0, 'DashboardFooter', first_line + i - 1, 0, -1)
  end

  utils.add_update_footer_command(config.bufnr, footer)
end

local function project_delete()
  api.nvim_create_user_command('DbProjectDelete', function(args)
    local path = utils.path_join(vim.fn.stdpath('cache'), 'dashboard', 'cache')
    utils.async_read(
      path,
      vim.schedule_wrap(function(data)
        local dump = assert(loadstring(data))
        local list = dump()
        local count = tonumber(args.args)
        if vim.tbl_count(list) < count then
          return
        end
        list = vim.list_slice(list, count + 1)
        local str = string.dump(assert(loadstring('return ' .. vim.inspect(list))))
        local handle = io.open(path, 'w+')
        if not handle then
          return
        end
        handle:write(str)
        handle:close()
      end)
    )
  end, {
    nargs = '+',
  })
end

local function theme_instance(config)
  project_list(config, function(plist)
    if not api.nvim_buf_is_valid(config.bufnr) then
      return
    end
    if config.disable_move then
      utils.disable_move_key(config.bufnr)
    end
    require('dashboard.theme.header').generate_header(config)
    if not config.shortcut or not vim.tbl_isempty(config.shortcut) then
      gen_shortcut(config)
    end
    load_packages(config)
    gen_center(plist, config)
    gen_footer(config)
    map_key(config, config.confirm_key or '<CR>')
    require('dashboard.events').register_lsp_root(config.path)
    local size = math.floor(vim.o.lines / 2)
      - math.ceil(api.nvim_buf_line_count(config.bufnr) / 2)
      - 2
    local fill = utils.generate_empty_table(size)
    api.nvim_buf_set_lines(config.bufnr, 0, 0, false, fill)
    vim.bo[config.bufnr].modifiable = false
    vim.bo[config.bufnr].modified = false
    --defer until next event loop
    vim.schedule(function()
      api.nvim_exec_autocmds('User', {
        pattern = 'DashboardLoaded',
        modeline = false,
      })
    end)
    project_delete()
  end)
end

return setmetatable({}, {
  __call = function(_, t)
    theme_instance(t)
  end,
})
