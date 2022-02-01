-- https://gist.github.com/justnom/9816256
local function tableToString(tbl)
    local result = "{"
    for k, v in pairs(tbl) do
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
        end

        if type(v) == "table" then
            result = result..tableToString(v)
        elseif type(v) == "boolean" then
            result = result..tostring(v)
        else
            result = result.."\""..v.."\""
        end
        result = result..","
    end
    if result ~= "" then
        result = result:sub(1, result:len()-1)
    end
    return result.."}"
end

local function stringToTable(str, regex)
  local array = {}
  for prefix, file in string.gmatch(str, regex) do
    table.insert(array, prefix)
    table.insert(array, file)
  end
  return array
end

local function navigation(fileName)
    vim.api.nvim_command('e ' .. fileName)
end

local function getPathState()
  local bufName = vim.api.nvim_buf_get_name(0)
  local pathToFile = stringToTable(bufName, '(.+)/(.+)$')
  local path = pathToFile[1]
  local fileName = pathToFile[2]
  local sections = stringToTable(fileName, '[%-%w_]+')
  local prefix = sections[1]

  local currentSuffix = '';
  local separator = '';
  for i = 2, #sections, 1 do
   currentSuffix = currentSuffix .. separator .. sections[i]
   separator = '.'
  end

  return {
    path = path,
    prefix = prefix,
    currentSuffix = currentSuffix
  }
end

-- Docs suggest 'vertical'|'horizontal' - anything works for horizontal.
-- However, in the future I plan to add 'window', so I want to use string and not boolean
local function openSplit(options)

  local size = options.size or '';
  local direction = options.split == 'vertical' and 'vsp' or 'sp'
  local command = size .. direction

  vim.api.nvim_command(command)
end

local function switch(suffix, options)
  local pathState = getPathState();

  if (options ~= nil and options.split ~= nil) then
    openSplit(options);
  end

  return navigation(pathState.path .. '/' .. pathState.prefix ..  '.' .. suffix)
end

local function toggle(suffixOne, suffixTwo)
  local pathState = getPathState();
  local suffix = suffixOne;
  if pathState.currentSuffix == suffix then
    suffix = suffixTwo
  end

  return navigation(pathState.path .. '/' .. pathState.prefix ..  '.' .. suffix)
end

return {
  toggle = toggle,
  switch = switch,
}

