# Nvim Quick Switcher
Quickly navigate to related/alternate files/extensions based on the current file name. Written in Lua.

https://user-images.githubusercontent.com/14320878/205079483-82f2cd39-915e-485a-a5c6-20b188e1b26b.mp4

## Features
- 🦕 Switch to files with common prefix (example: "tasks"):
  - `tasks.component.ts` --> `tasks.component.html`
  - `tasks.component.html` --> `tasks.component.scss`
  - `tasks.component.scss` --> `tasks.component.ts`
- 🦎 Toggle between file extensions
  - `tasks.cpp` <--> `tasks.h`
  - `tasks.html` <--> `tasks.css`
- 🐙 Switch to files with different suffix
  - `tasks.component.ts` --> `tasks.module.ts`
  - `tasks.component.ts` --> `tasks.component.spec.ts`
  - `tasks.query.ts` --> `tasks.store.ts`
- 🐒 Find files by Wilcard (Glob) or Regex 
  - `tasks.ts` --> `tasks.spec.ts` | `tasks.test.ts` 
  - `tasks.ts` --> `tasks.css` | `tasks.scss` | `tasks.sass`
  - `/tasks.components.ts` --> `state/tasks.query.ts` 
  - `state/tasks.query.ts` --> `../tasks.component.ts`
  - `controller.lua` --> `controller_spec.lua`
  - `controller-util.lua` --> `controller-service.lua`
- 🌳 Navigate inside files with Treesitter Queries

## Installation
Vim-plug 
```vim
Plug 'Everduin94/nvim-quick-switcher'
```

Packer
```lua
use {
  "Everduin94/nvim-quick-switcher",
}
```

## Usage

Switcher has 4 functions. `switch`, `toggle`, `find`, `inline_ts_switch`. No setup function call required. Just call a function with the desired arguments.

For more examples, see `Recipes`

### ➡️ Switch
*Gets "prefix" of file name, switches to `prefix`.`suffix`*

`switch(search_string, options)`

#### Example

`require('nvim-quick-switcher').switch('component.ts')`
- `ticket.component.html` --> `ticket.component.ts`

#### Options
```lua
{
  split = 'vertical'|'horizontal'|nil -- nil is default
  size = 100 -- # of columns | rows. default is 50% split
  ignore_prefix = false -- useful for navigating to files like "index.ts" or "+page.svelte"
}
```

### 🔄 Toggle
*Toggles `prefix`.`suffix`, based on current suffix / file extension*

`toggle(search_string_one, search_string_two, options)`

For `options` see `Common Options`

#### Example
`require('nvim-quick-switcher').toggle('cpp', 'h')`
- `node.cpp` --> `node.h`
- `node.h` --> `node.cpp`

### 🔍 Find 
*Uses gnu/linux `find` & `grep` to find file and switch to `prefix`+`pattern`*

`find(search_string, options)`

#### Example
`require('nvim-quick-switcher').find('*query*')`
- Allows wild cards, i.e. first argument is search parameter for gnu/linux find
- file: `ticket.component.ts` --> pattern: `ticket*query*`

`require('nvim-quick-switcher').find('.+css|.+scss|.+sass', { regex = true })`
- Uses find, then filters via grep regex, i.e. first argument is regex
- file: `ticket.component.ts` --> find: `ticket*` --> grep: `.+css|.+scss|.+sass`
- When using backslash, may have to escape via `\\`

If multiple matches are found will prompt UI Select.
- You can use options like `prefix` or `regex` to make your searches more specific. See `Recipes` for examples.

If no results are found, will search backwards one directory, see `reverse`

#### Options 
```lua
{
  split = 'vertical'|'horizontal'|nil
  size = 100 
  regex = false, -- If true, first argument uses regex instead of find string/wildcard.
  maxdepth = 2, -- directory depth 
  reverse = true, -- false will disable reverse search when no results are found
  path = nil, -- overwrite path (experimental).
  prefix = 'default', 
    -- full: stop at last period
    -- short: stop at first _ or -
    -- long: stop at last _ 
    -- default: stop at first period.
    -- lua function (you can pass a lua function to create a custom prefix)
  regex_type = 'E' -- default regex extended. See grep for types.
  ignore_prefix = false -- useful for navigating to files like "index.ts" or "+page.svelte"
  drop = false -- if true, drop instead of edit
}
```

### 🌳 Inline Switch (Treesitter)
Requires `nvim-treesitter/nvim-treesitter`

*Uses treesitter queries to navigate inside of a file*

`inline_ts_switch(file_type, query_string, options)`

#### Example
`require('nvim-quick-switcher').inline_ts_switch('svelte', '(script_element (end_tag) @capture)')`
- Places cursor at start of `</script>` node

#### Options 
```lua
{
  goto_end = false, -- go to start of node if false, go to end of node if true
  avoid_set_jump = false, -- do not add to jumplist if true
}
```

### 🚀 Find by Function (Advanced)
Accepts a lua function that provides path/file information as an argument, and returns a file path as a string. Useful for switching across directories / folders.
i.e. the user is provided file path data to then build an entire file path, that gets passed to vim select, that gets passed to navigate.

`require('nvim-quick-switcher').find_by_fn(fn, options)`

#### Example

This example switches from a test folder to a src folder (and vice versa) like in to a Java J-Unit project.

```lua
local ex_find_test_fn = function (p)
  local path = p.path;
  local file_name = p.prefix;
  local result = path:gsub('src', 'test') .. '/' .. file_name .. '*';
  return result;
end

local find_src_fn = function (p)
  local path = p.path;
  local file_name = p.prefix;
  local result = path:gsub('test', 'src') .. '/' .. file_name .. '*';
  return result;
end

require('nvim-quick-switcher').find_by_fn(ex_find_test_fn)
require('nvim-quick-switcher').find_by_fn(find_src_fn)
```

#### Args
```lua
prefix -- The prefix of the file (task.component.ts) --> task
full_prefix -- (task.component.ts) --> task.component
full_suffix -- (task.component.ts) --> component.ts
short_prefix -- (task-util.lua) --> task
file_type -- (task-util.lua) --> lua
file_name -- (src/tasks/task-util.lua) --> task-util.lua
path -- (src/tasks/task-util.lua) --> src/tasks/task-util.lua
```

### 🌌 Common Options
Options common for file location functions (`switch/toggle/find/find_by_fn`).
```lua
{
  only_existing = false,
  only_existing_notify = false,
}
```
`only_existing` Causes the switcher to check if the target file exists
before switching to it.
`only_existing_notify` will print if the file does not exist.


## Recipes (My Keymaps)
*My configuration for nvim-quick-switcher. Written in Lua*

```lua
local opts = { noremap = true, silent = true }

local function find(file_regex, opts)
  return function() require('nvim-quick-switcher').find(file_regex, opts) end
end

local function inline_ts_switch(file_type, scheme)
  return function() require('nvim-quick-switcher').inline_ts_switch(file_type, scheme) end
end

local function find_by_fn(fn, opts)
  return function() require('nvim-quick-switcher').find_by_fn(fn, opts) end
end

-- Styles
vim.keymap.set("n", "<leader>oi", find('.+css|.+scss|.+sass', { regex = true, prefix='full' }), opts)

-- Types
vim.keymap.set("n", "<leader>orm", find('.+model.ts|.+models.ts|.+types.ts', { regex = true }), opts)

-- Util
vim.keymap.set("n", "<leader>ol", find('*util.*', { prefix = 'short' }), opts)

-- Tests
vim.keymap.set("n", "<leader>ot", find('.+test|.+spec', { regex = true, prefix='full' }), opts)

-- Project Specific Keymaps
-- * Maps keys based on project using an auto command. Ideal for reusing keymaps based on context.
-- * Example: In Angular, `oo` switches to .component.html. In Svelte, `oo` switches to *page.svelte
vim.api.nvim_create_autocmd({'UIEnter'}, {
    callback = function(event)
      local is_angular = next(vim.fs.find({ "angular.json", "nx.json" }, { upward = true }))
      local is_svelte = next(vim.fs.find({ "svelte.config.js", "svelte.config.ts" }, { upward = true }))

      -- Angular
      if is_angular then
        print('Angular')
        vim.keymap.set("n", "<leader>oo", find('.component.html'), opts)
        vim.keymap.set("n", "<leader>ou", find('.component.ts'), opts)
        vim.keymap.set("n", "<leader>op", find('.module.ts'), opts)
        vim.keymap.set("n", "<leader>oy", find('.service.ts'), opts)
      end

      -- SvelteKit
      if is_svelte then
        print('Svelte')
        vim.keymap.set("n", "<leader>oo", find('*page.svelte', { maxdepth = 1, ignore_prefix = true }), opts)
        vim.keymap.set("n", "<leader>ou", find('.*page.server(.+js|.+ts)|.*page(.+js|.+ts)', { maxdepth = 1, regex = true, ignore_prefix = true }), opts)
        vim.keymap.set("n", "<leader>op", find('*layout.svelte', { maxdepth = 1, ignore_prefix = true }), opts)

         -- Inline TS
        vim.keymap.set("n", "<leader>oj", inline_ts_switch('svelte', '(script_element (end_tag) @capture)'), opts)
        vim.keymap.set("n", "<leader>ok", inline_ts_switch('svelte', '(style_element (start_tag) @capture)'), opts)
      end
    end
})

-- Redux-like
vim.keymap.set("n", "<leader>ore", find('*effects.ts'), opts)
vim.keymap.set("n", "<leader>ora", find('*actions.ts'), opts)
vim.keymap.set("n", "<leader>orw", find('*store.ts'), opts)
vim.keymap.set("n", "<leader>orf", find('*facade.ts'), opts)
vim.keymap.set("n", "<leader>ors", find('.+query.ts|.+selectors.ts|.+selector.ts', { regex = true }), opts)
vim.keymap.set("n", "<leader>orr", find('.+reducer.ts|.+repository.ts', { regex = true }), opts)

-- Java J-Unit (Advanced Example)
local find_test_fn = function (p)
  local path = p.path;
  local file_name = p.prefix;
  local result = path:gsub('src', 'test') .. '/' .. file_name .. '*';
  return result;
end

local find_src_fn = function (p)
  local path = p.path;
  local file_name = p.prefix;
  local result = path:gsub('test', 'src') .. '/' .. file_name .. '*';
  return result;
end

vim.keymap.set("n", "<leader>ojj", find_by_fn(find_test_fn), opts)
vim.keymap.set("n", "<leader>ojk", find_by_fn(find_src_fn), opts)
```

## Personal Motivation
Many moons ago, as a sweet summer child, I used VS Code with an extension called "Angular Switcher".
Angular switcher enables switching to various file extensions related to the current component.

I wanted to take that idea and make it work for many frameworks or file extensions

I currently use nvim-quick-switcher on a daily basis for Svelte / Svelte-Kit, Angular Components, Tests, Stylesheets, Lua util files, and Redux-like files.

## Alternatives
- [projectionist](https://github.com/tpope/vim-projectionist)
