local api = vim.api
local utils = require('dashboard.utils')

local function week_ascii_text()
  return {
    ['Monday'] = {
      '',
      '███╗   ███╗ ██████╗ ███╗   ██╗██████╗  █████╗ ██╗   ██╗',
      '████╗ ████║██╔═══██╗████╗  ██║██╔══██╗██╔══██╗╚██╗ ██╔╝',
      '██╔████╔██║██║   ██║██╔██╗ ██║██║  ██║███████║ ╚████╔╝ ',
      '██║╚██╔╝██║██║   ██║██║╚██╗██║██║  ██║██╔══██║  ╚██╔╝  ',
      '██║ ╚═╝ ██║╚██████╔╝██║ ╚████║██████╔╝██║  ██║   ██║   ',
      '╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   ',
      '',
    },
    ['Tuesday'] = {
      '',
      '████████╗██╗   ██╗███████╗███████╗██████╗  █████╗ ██╗   ██╗',
      '╚══██╔══╝██║   ██║██╔════╝██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝',
      '   ██║   ██║   ██║█████╗  ███████╗██║  ██║███████║ ╚████╔╝ ',
      '   ██║   ██║   ██║██╔══╝  ╚════██║██║  ██║██╔══██║  ╚██╔╝  ',
      '   ██║   ╚██████╔╝███████╗███████║██████╔╝██║  ██║   ██║   ',
      '   ╚═╝    ╚═════╝ ╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   ',
      '',
    },
    ['Wednesday'] = {
      '',
      '██╗    ██╗███████╗██████╗ ███╗   ██╗███████╗███████╗██████╗  █████╗ ██╗   ██╗',
      '██║    ██║██╔════╝██╔══██╗████╗  ██║██╔════╝██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝',
      '██║ █╗ ██║█████╗  ██║  ██║██╔██╗ ██║█████╗  ███████╗██║  ██║███████║ ╚████╔╝ ',
      '██║███╗██║██╔══╝  ██║  ██║██║╚██╗██║██╔══╝  ╚════██║██║  ██║██╔══██║  ╚██╔╝  ',
      '╚███╔███╔╝███████╗██████╔╝██║ ╚████║███████╗███████║██████╔╝██║  ██║   ██║   ',
      ' ╚══╝╚══╝ ╚══════╝╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   ',
      '',
    },
    ['Thursday'] = {
      '',
      '████████╗██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗  █████╗ ██╗   ██╗',
      '╚══██╔══╝██║  ██║██║   ██║██╔══██╗██╔════╝██╔══██╗██╔══██╗╚██╗ ██╔╝',
      '   ██║   ███████║██║   ██║██████╔╝███████╗██║  ██║███████║ ╚████╔╝ ',
      '   ██║   ██╔══██║██║   ██║██╔══██╗╚════██║██║  ██║██╔══██║  ╚██╔╝  ',
      '   ██║   ██║  ██║╚██████╔╝██║  ██║███████║██████╔╝██║  ██║   ██║   ',
      '   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   ',
      '',
    },
    ['Friday'] = {
      '',
      '███████╗██████╗ ██╗██████╗  █████╗ ██╗   ██╗',
      '██╔════╝██╔══██╗██║██╔══██╗██╔══██╗╚██╗ ██╔╝',
      '█████╗  ██████╔╝██║██║  ██║███████║ ╚████╔╝ ',
      '██╔══╝  ██╔══██╗██║██║  ██║██╔══██║  ╚██╔╝  ',
      '██║     ██║  ██║██║██████╔╝██║  ██║   ██║   ',
      '╚═╝     ╚═╝  ╚═╝╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   ',
      '',
    },
    ['Saturday'] = {
      '',
      '███████╗ █████╗ ████████╗██╗   ██╗██████╗ ██████╗  █████╗ ██╗   ██╗',
      '██╔════╝██╔══██╗╚══██╔══╝██║   ██║██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝',
      '███████╗███████║   ██║   ██║   ██║██████╔╝██║  ██║███████║ ╚████╔╝ ',
      '╚════██║██╔══██║   ██║   ██║   ██║██╔══██╗██║  ██║██╔══██║  ╚██╔╝  ',
      '███████║██║  ██║   ██║   ╚██████╔╝██║  ██║██████╔╝██║  ██║   ██║   ',
      '╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   ',
      '',
    },
    ['Sunday'] = {
      '',
      '███████╗██╗   ██╗███╗   ██╗██████╗  █████╗ ██╗   ██╗',
      '██╔════╝██║   ██║████╗  ██║██╔══██╗██╔══██╗╚██╗ ██╔╝',
      '███████╗██║   ██║██╔██╗ ██║██║  ██║███████║ ╚████╔╝ ',
      '╚════██║██║   ██║██║╚██╗██║██║  ██║██╔══██║  ╚██╔╝  ',
      '███████║╚██████╔╝██║ ╚████║██████╔╝██║  ██║   ██║   ',
      '╚══════╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝   ╚═╝   ',
      '',
    },
  }
end

local function default_header()
  return {
    '',
    ' ██████╗  █████╗ ███████╗██╗  ██╗██████╗  ██████╗  █████╗ ██████╗ ██████╗  ',
    ' ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██╔══██╗ ',
    ' ██║  ██║███████║███████╗███████║██████╔╝██║   ██║███████║██████╔╝██║  ██║ ',
    ' ██║  ██║██╔══██║╚════██║██╔══██║██╔══██╗██║   ██║██╔══██║██╔══██╗██║  ██║ ',
    ' ██████╔╝██║  ██║███████║██║  ██║██████╔╝╚██████╔╝██║  ██║██║  ██║██████╔╝ ',
    ' ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ',
    '',
  }
end

-- Example flf2a$ 7 7 13 0 7 0 64 0
local function parse_flf_header(sigil_string)
  local fig_header = {}
  local i = 1
  for v in sigil_string:gmatch('%w+') do
    if i == 2 then
      fig_header['height'] = tonumber(v)
    end
    if i == 3 then
      fig_header['baseline'] = tonumber(v)
    end
    if i == 4 then
      fig_header['max_length'] = tonumber(v)
    end
    if i == 5 then
      fig_header['old_layout'] = tonumber(v)
    end
    if i == 6 then
      fig_header['comment_lines'] = tonumber(v)
    end
    if i == 7 then
      fig_header['print_direction'] = tonumber(v)
    end
    if i == 8 then
      fig_header['full_layout'] = tonumber(v)
    end
    if i == 9 then
      fig_header['codetag_count'] = tonumber(v)
    end
    i = i + 1
  end
  return fig_header
end

-- WARN :This is by no means full support for fliglet fonts.
local function flf_table_gen(font_type)
  local flf_table = {}
  local flf_header = nil
  local i = 1
  local byte = 32 -- start byte offsest to ascii space
  local flf, flf_err = io.open(font_type, 'r')
  if flf_err then
    print(flf_err)
    return default_header()
  end
  local value = flf:read('*l')

  while value do
    if flf_header == nil then
      if string.sub(value, 0, 6) == 'flf2a$' then
        flf_header = parse_flf_header(value)
      end
    elseif i > flf_header.comment_lines + 1 then
      local symbol_line = ((i - flf_header.comment_lines - 2) % flf_header.height) + 1
      if symbol_line == 1 then
        flf_table[byte] = {}
      end

      value = string.gsub(value, '%$', ' ')
      value = string.gsub(value, '@', '')

      flf_table[byte][symbol_line] = value
      if symbol_line == 7 then
        byte = byte + 1
      end
    end
    value = flf:read('*l')
    i = i + 1
  end

  return flf_table, flf_header
end

local function string_to_bytes_list(str)
  local str_bytes = {}
  for i in str:gmatch('.') do
    table.insert(str_bytes, string.byte(i))
  end
  return str_bytes
end

local function custom_header(input, font_type)
  local input_bytes = string_to_bytes_list(input)
  local font_path = utils.path_join(utils.get_plugin_path(), 'fonts', (font_type .. '.flf'))
  local tbl, head = flf_table_gen(font_path)
  local output = {}
  for i = 1, head['height'] do
    output[i] = ''
    for _, v in pairs(input_bytes) do
      output[i] = output[i] .. tbl[v][i]
    end
  end
  return output
end

local function week_header(concat, append)
  local week = week_ascii_text()
  local daysoftheweek =
    { 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday' }
  local day = daysoftheweek[os.date('*t').wday]
  local tbl = week[day]
  table.insert(tbl, os.date('%Y-%m-%d %H:%M:%S ') .. (concat or ''))
  if append then
    vim.list_extend(tbl, append)
  end
  table.insert(tbl, '')
  return tbl
end

local function generate_header(config)
  if not vim.bo[config.bufnr].modifiable then
    vim.bo[config.bufnr].modifiable = true
  end
  if not config.command then
    local header = nil
    if config.header.type == 'week' then
      header = week_header(config.header.concat, config.header.append)
    elseif config.header.type == 'custom' then
      header = custom_header(config.header.text, config.header.font)
    else
      header = default_header()
    end
    api.nvim_buf_set_lines(config.bufnr, 0, -1, false, utils.center_align(header))

    for i, _ in ipairs(header) do
      vim.api.nvim_buf_add_highlight(config.bufnr, 0, 'DashboardHeader', i - 1, 0, -1)
    end
    return
  end

  local empty_table = utils.generate_empty_table(config.file_height + 4)
  api.nvim_buf_set_lines(config.bufnr, 0, -1, false, utils.center_align(empty_table))
  local preview = require('dashboard.preview')
  preview:open_preview({
    width = config.file_width,
    height = config.file_height,
    cmd = config.command .. ' ' .. config.file_path,
  })
end

return {
  generate_header = generate_header,
}
