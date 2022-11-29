local util = require('nvim-quick-switcher.util')

local M = {}

-- Docs suggest 'vertical'|'horizontal' - anything works for horizontal.
-- However, in the future I plan to add 'window', so I want to use string and not boolean
local function openSplit(options)
  local size = options.size or '';
  local direction = options.split == 'vertical' and 'vsp' or 'sp'
  vim.api.nvim_command(size .. direction)
end

local function navigation(file_name, options)
  local isSplit = options ~= nil and options.split ~= nil
  if (isSplit) then
    openSplit(options);
  end
    vim.api.nvim_command('e ' .. file_name)
end

local function selection(items, options)
      return vim.ui.select(
        items,
        { prompt = 'Multiple matches found:', format_item = function(item) return item end, },
        function(choice) if choice then navigation(choice, options) end end
     )
end

local function get_path_state()
  local buf_name = vim.api.nvim_buf_get_name(0)
  local path = buf_name:match('(.+)/.+$')
  local file_name = buf_name:match('.+/(.+)$')
  local prefix = file_name:match('[%-%w_]+')
  local full_suffix = file_name:match('[%-%w_]+%.(.*)')
  local full_prefix = file_name:match('([%-%w_%.]+)%.%w+$')
  local short_prefix = file_name:match('[%w]+')
  return {
    path = path,
    prefix = prefix,
    full_prefix = full_prefix,
    full_suffix = full_suffix,
    short_prefix = short_prefix,
    file_name = file_name
  }
end

-- Instead of '.' config/options. Create flexible call-back function.
function M.switch(suffix, user_config)
  local path_state = get_path_state();
  if user_config.ignore_prefix then path_state.prefix = '' end
  return navigation(path_state.path .. '/' .. path_state.prefix ..  '.' .. suffix, user_config)
end

function M.toggle(suffixOne, suffixTwo)
  local path_state = get_path_state();
  local suffix = suffixOne;
  if path_state.full_suffix == suffix then
    suffix = suffixTwo
  end

  return navigation(path_state.path .. '/' .. path_state.prefix ..  '.' .. suffix)
end

function M.find(input, user_config)
    local config = util.prop_factory(util.default_find_config(), user_config)
    local path_state = get_path_state();
    local path = config.path and config.path or path_state.path
    local prefix = util.resolve_prefix(path_state, config.prefix)
    if user_config.ignore_prefix then prefix = '' end
    local base_find = [[find ]] .. path .. [[ -maxdepth ]] .. config.maxdepth
    local name_based = ' -name ' .. [[']] .. prefix .. input .. [[']]
    local regex_based = ' -name ' .. [[']] .. prefix .. [[*']] .. [[ | grep ]] .. '-' .. config.regex_type  .. [[ ']] .. input .. [[']]
    local search = config.regex and base_find .. regex_based or base_find .. name_based
    local output = util.readCmd(search)
    local matches = util.listToTable(output, function (item)
      local file_name = item:match('.+/(.+)$')
      return path_state.file_name == file_name
    end);

    if #matches == 1 then
      navigation(matches[1], config)
    elseif #matches > 1 then
      selection(matches, config)
    else
     if config.reverse then
       M.find(input, { maxdepth = 1, path = path .. '/..', reverse = false, regex = config.regex })
     end
    end
end

return M;
