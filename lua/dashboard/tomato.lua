local tomato = {}

function tomato.header_title()
  local day = os.date("%A")
  return {day .. ' Tasks:   Wasting time is robbing oneself.'}
end

function tomato.get_all_tasks()
end

function tomato.add_task()
end

function tomato.delete_task()
end

function tomato.edit_task()
end

return tomato
