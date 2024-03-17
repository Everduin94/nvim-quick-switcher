local util = require('nvim-quick-switcher.util')
local ts = require('nvim-quick-switcher.ts')

local M = {}

-- Docs suggest 'vertical'|'horizontal' - anything works for horizontal.
-- However, in the future I plan to add 'window', so I want to use string and not boolean
local function openSplit(options)
  local size = options.size or '';
  local direction = options.split == 'vertical' and 'vsp' or 'sp'
  vim.api.nvim_command(size .. direction)
end

local function navigation(file_name, options)
  local isDrop = options ~= nil and options.drop ~= nil
  local isSplit = options ~= nil and options.split ~= nil

  local checkIfExists = options ~= nil and options.only_existing
  if (checkIfExists and vim.fn.filereadable(file_name) == 0) then
    if (options.only_existing_notify) then vim.print(file_name .. ' does not exist.') end
    return;
  end

  if (isSplit) then
    openSplit(options);
  end

  if (isDrop) then
    vim.api.nvim_command('drop ' .. file_name)
  else
    vim.api.nvim_command('e ' .. file_name)
  end
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
  local file_type = file_name:match('^.+%.(.+)$')
  local full_suffix = file_name:match('[%-%w_]+%.(.*)')
  local full_prefix = file_name:match('([%-%w_%.]+)%.%w+$')
  local short_prefix = file_name:match('[%w]+')
  local long_prefix = file_name:match("([%w_%-]+)[%-_]")
  return {
    path = path,
    prefix = prefix,
    full_prefix = full_prefix,
    full_suffix = full_suffix,
    short_prefix = short_prefix,
    long_prefix = long_prefix,
    file_type = file_type,
    file_name = file_name
  }
end

-- Instead of '.' config/options. Create flexible call-back function.
function M.switch(suffix, user_config)
  local path_state = get_path_state();
  local ignore_prefix = user_config ~= nil and user_config.ignore_prefix == true
  local prefix = path_state.prefix .. '.'
  if ignore_prefix then prefix = '' end
  return navigation(path_state.path .. '/' .. prefix .. suffix, user_config)
end

function M.toggle(suffixOne, suffixTwo, user_config)
  local path_state = get_path_state();
  local suffix = suffixOne;
  if path_state.full_suffix == suffix then
    suffix = suffixTwo
  end

  return navigation(path_state.path .. '/' .. path_state.prefix .. '.' .. suffix, user_config)
end

function M.inline_ts_switch(file_type, query_string, user_config)
  local config = util.prop_factory(util.default_inline_config(), user_config)
  local query = vim.treesitter.parse_query(file_type, query_string)
  ts.go_to_node(file_type, query, config.goto_end, config.avoid_set_jump)
end

function M.find_by_fn(fn, user_config)
  local config = util.prop_factory(util.default_find_config(), user_config)
  local path_state = get_path_state();
  local full_user_input = fn(path_state);
  local full_user_path = full_user_input:match('(.+)/.+$')
  local user_file_name = full_user_input:match('.+/(.+)$')
  local base_find = [[find ]] .. full_user_path .. [[ -maxdepth ]] .. config.maxdepth
  local name_based = ' -name ' .. [[']] .. user_file_name .. [[']]
  local search = base_find .. name_based
  local output = util.readCmd(search)
  local matches = util.listToTable(output, function(item)
    local file_name = item:match('.+/(.+)$')
    return path_state.file_name == file_name
  end);
  if #matches == 1 then
    navigation(matches[1], config)
  elseif #matches > 1 then
    selection(matches, config)
  end
end

function M.find(input, user_config)
  local config = util.prop_factory(util.default_find_config(), user_config)
  local path_state = get_path_state();
  local path = config.path and config.path or path_state.path
  local prefix = util.resolve_prefix(path_state, config.prefix)
  if config.ignore_prefix then prefix = '' end
  local base_find = [[find ]] .. path .. [[ -maxdepth ]] .. config.maxdepth
  local name_based = ' -name ' .. [[']] .. prefix .. input .. [[']]
  local regex_based = ' -name ' ..
      [[']] .. prefix .. [[*']] .. [[ | grep ]] .. '-' .. config.regex_type .. [[ ']] .. input .. [[']]
  local search = config.regex and base_find .. regex_based or base_find .. name_based
  local output = util.readCmd(search)
  local matches = util.listToTable(output, function(item)
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
