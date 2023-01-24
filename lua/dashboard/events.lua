local api, lsp, uv = vim.api, vim.lsp, vim.loop
local utils = require('dashboard.utils')
local au = {}

function au.register_lsp_root(path)
  api.nvim_create_autocmd('VimLeavePre', {
    callback = function()
      local projects = {}
      for _, client in pairs(lsp.get_active_clients() or {}) do
        local root_dir = client.config.root_dir
        if root_dir and not vim.tbl_contains(projects, root_dir) then
          table.insert(projects, root_dir)
        end

        for _, folder in pairs(client.workspace_folders or {}) do
          if not vim.tbl_contains(projects, folder.name) then
            table.insert(projects, folder.name)
          end
        end
      end

      if #projects == 0 then
        return
      end

      utils.async_write(path, function(fd, data)
        local before = assert(loadstring(data))
        local plist = before()
        plist = vim.tbl_filter(function(k)
          return not vim.tbl_contains(projects, k)
        end, plist or {})
        plist = vim.list_extend(plist, projects)
        local fn = assert(loadstring('return ' .. vim.inspect(plist)))
        local dump = string.dump(fn)
        uv.fs_write(fd, dump, 0, function(err, _)
          assert(not err, err)
          uv.fs_close(fd)
        end)
      end)
    end,
  })
end

return au
