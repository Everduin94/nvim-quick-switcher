local M = {}

function M.listToTable(list, filterFn)
  local t = {}
  for item in list:gmatch("[^\r\n]+") do
    if (not filterFn or not filterFn(item)) then
      table.insert(t, item);
    else
    end
  end
  return t
end

function M.readCmd(cmd)
  local handle = io.popen(cmd);
  local result = handle:read('*a')
  handle:close()
  return result;
end

function M.prop_factory(defaults, props)
  if props == nil then
      return defaults
  end

  for k, v in pairs(props) do
    defaults[k] = v
  end

  return defaults;
end

function M.resolve_prefix(path_state, option)
	if type(option) == "string" then
		if option == "short" then
			return path_state.short_prefix
		elseif option == "full" then
			return path_state.full_prefix
		elseif option == "long" then
			return path_state.long_prefix
		else
			return path_state.prefix
		end
	elseif type(option) == "function" then
		local buf_name = vim.api.nvim_buf_get_name(0)
		local file_name = buf_name:match(".+/(.+)%.")
		local file_extension = buf_name:match(".+%.(%w+)$")
		local custom_prefix = option(file_name, file_extension)
		if custom_prefix == nil then
			return path_state.prefix
		end
		return custom_prefix
	end
end

function M.default_inline_config()
  return {
      goto_end = false,
      avoid_set_jump = false,
    }
end

function M.default_find_config()
  return {
      maxdepth = 2,
      regex = false,
      path = nil,
      reverse = true,
      prefix = 'default',
      regex_type = 'E',
      ignore_prefix = false
    }
end

return M
