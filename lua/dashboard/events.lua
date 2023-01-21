local api, lsp, uv = vim.api, vim.lsp, vim.loop
local au = {}

function au.register_lsp_root(path)
  api.nvim_create_autocmd('BufDelete', {
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

      uv.fs_open(path, 'rs+', tonumber('664', 8), function(err, fd)
        assert(not err, err)
        uv.fs_fstat(fd, function(err, stat)
          assert(not err, err)
          uv.fs_read(fd, stat.size, 0, function(err, data)
            assert(not err, err)
            local before = assert(loadstring(data))
            local plist = before()
            plist = vim.list_extend(plist or {}, projects)
            local fn = assert(loadstring('return ' .. vim.inspect(plist)))
            local dump = string.dump(fn)
            uv.fs_write(fd, dump, 0, function(err, bytes)
              assert(not err, err)
              uv.fs_close(fd)
            end)
          end)
        end)
      end)
    end,
  })
end

return au
