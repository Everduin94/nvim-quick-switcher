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

local function tableIncludes(sections, phrases)
  for _,v in pairs(sections) do
    for k,j in pairs(phrases) do
      if v == j then
        return true
      end
    end
  end
  return false
end

local function navigation(fileName)
    print(fileName)
    vim.api.nvim_command('e ' .. fileName)
end

local function setup(config)
  local opts = { noremap = true, silent = true }
  local keymap = vim.api.nvim_set_keymap
  for _, entry in pairs(config) do
    keymap("n", entry.mapping, ":lua require('nvim-quick-switcher').switchTo(" .. tableToString(entry.matchers) .. ")<CR>", opts)
  end
end

local function switchTo(config)
  local bufName = vim.api.nvim_buf_get_name(0)
  local pathToFile = stringToTable(bufName, '(.+)/(.+)$')
  local path = pathToFile[1]
  local fileName = pathToFile[2]
  local sections = stringToTable(fileName, '%w+')
  -- TODO: substring buffer prefix on filename to get buffer suffix. If matches suffix, noop.
  for _,v in pairs(config) do
    local hasMatch = tableIncludes(sections, v.matches)
    if hasMatch then
      local prefix = sections[1]
      return navigation(path .. '/' .. prefix ..  '.' .. v.suffix)
    end
  end
end

return {
  setup = setup,
  switchTo = switchTo,
}

