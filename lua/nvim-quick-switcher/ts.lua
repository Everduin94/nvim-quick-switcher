-- TS Utils
local M = {}

local ts_utils = require 'nvim-treesitter.ts_utils'

local get_root = function(bufnr, file_type)
  local parser = vim.treesitter.get_parser(bufnr, file_type, {})
  local tree = parser:parse()[1]
  return tree:root()
end

M.go_to_node = function(file_type, query, goto_end, avoid_set_jump)
  local bufnr = vim.api.nvim_get_current_buf()
  if vim.bo[bufnr].filetype ~= file_type then
    return
  end

  local root = get_root(bufnr, file_type)
  for id, node in query:iter_captures(root, bufnr, 0, -1) do
    ts_utils.goto_node(node, goto_end, avoid_set_jump)
    return
  end
end
-- End

return M
