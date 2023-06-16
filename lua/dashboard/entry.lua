local api = vim.api
local nvim_buf_set_keymap = api.nvim_buf_set_keymap
local add_highlight = api.nvim_buf_add_highlight
local buf_set_lines, buf_set_extmark = api.nvim_buf_set_lines, api.nvim_buf_set_extmark
local ns = api.nvim_create_namespace('dashboard')
local entry = {}

local function box()
  local t = {}
  t.__index = t

  function t:append(lines)
    local bufnr = self.bufnr
    if type(lines) == 'string' then
      lines = { lines }
    elseif type(lines) == 'function' then
      lines = lines()
    end
    local count = api.nvim_buf_line_count(bufnr)
    buf_set_lines(bufnr, count, -1, false, lines)

    local obj = {}

    function obj:iterate()
      local index = 1
      return function()
        local line = lines[index]
        index = index + 1
        return line
      end
    end

    function obj:hi(callback)
      local iter = self:iterate()
      local index = -1
      for data in iter do
        index = index + 1
        if callback then
          local hi = callback(data, count + index)
          if hi then
            add_highlight(bufnr, ns, hi, count + index, 0, -1)
          end
        end
      end

      return obj
    end

    function obj:tailbtn(callback)
      local iter = self:iterate()
      local index = -1
      for data in iter do
        index = index + 1
        local btn, hi, action = callback(data)
        if btn then
          buf_set_extmark(bufnr, ns, count + index, 0, {
            virt_text = { { btn, hi } },
          })

          nvim_buf_set_keymap(bufnr, 'n', btn, '', {
            callback = function()
              if type(action) == 'string' then
                vim.cmd(action)
              elseif type(action) == 'function' then
                action()
              end
            end,
          })
        end
      end

      return obj
    end

    return setmetatable(obj, t)
  end

  return t
end

function entry:new(wininfo)
  return setmetatable(wininfo, box())
end

return entry
