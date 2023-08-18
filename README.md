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

`toggle(search_string_one, search_string_two)`

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

## Recipes (My Binds)
*My configuration for nvim-quick-switcher. Written in Lua*

```lua
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Styles
keymap("n", "<leader>oi", "<cmd>:lua require('nvim-quick-switcher').find('.+css|.+scss|.+sass', { regex = true, prefix='full' })<CR>", opts)

-- Types
keymap("n", "<leader>orm", "<cmd>:lua require('nvim-quick-switcher').find('.+model.ts|.+models.ts|.+types.ts', { regex = true })<CR>", opts)

-- Util
keymap("n", "<leader>ol", "<cmd>:lua require('nvim-quick-switcher').find('*util.*', { prefix = 'short' })<CR>", opts)

-- Tests
keymap("n", "<leader>ot", "<cmd>:lua require('nvim-quick-switcher').find('.+test|.+spec', { regex = true, prefix='full' })<CR>", opts)

-- Angular
keymap("n", "<leader>oy", "<cmd>:lua require('nvim-quick-switcher').find('.service.ts')<CR>", opts)
keymap("n", "<leader>ou", "<cmd>:lua require('nvim-quick-switcher').find('.component.ts')<CR>", opts)
keymap("n", "<leader>oo", "<cmd>:lua require('nvim-quick-switcher').find('.component.html')<CR>", opts)
keymap("n", "<leader>op", "<cmd>:lua require('nvim-quick-switcher').find('.module.ts')<CR>", opts)

-- SvelteKit
keymap("n", "<leader>oso", "<cmd>:lua require('nvim-quick-switcher').find('*page.svelte', { maxdepth = 1, ignore_prefix = true })<CR>", opts)
keymap("n", "<leader>osi", "<cmd>:lua require('nvim-quick-switcher').find('*layout.svelte', { maxdepth = 1, ignore_prefix = true })<CR>", opts)
keymap("n", "<leader>osu", "<cmd>:lua require('nvim-quick-switcher').find('.*page.server(.+js|.+ts)|.*page(.+js|.+ts)', { maxdepth = 1, regex = true, ignore_prefix = true })<CR>", opts)

 -- Inline TS
keymap("n", "<leader>osj", "<cmd>:lua require('nvim-quick-switcher').inline_ts_switch('svelte', '(script_element (end_tag) @capture)')<CR>", opts)
keymap("n", "<leader>osk", "<cmd>:lua require('nvim-quick-switcher').inline_ts_switch('svelte', '(style_element (start_tag) @capture)')<CR>", opts)

-- Redux-like
keymap("n", "<leader>ore", "<cmd>:lua require('nvim-quick-switcher').find('*effects.ts')<CR>", opts)
keymap("n", "<leader>ora", "<cmd>:lua require('nvim-quick-switcher').find('*actions.ts')<CR>", opts)
keymap("n", "<leader>orw", "<cmd>:lua require('nvim-quick-switcher').find('*store.ts')<CR>", opts)
keymap("n", "<leader>orf", "<cmd>:lua require('nvim-quick-switcher').find('*facade.ts')<CR>", opts)
keymap("n", "<leader>ors", "<cmd>:lua require('nvim-quick-switcher').find('.+query.ts|.+selectors.ts|.+selector.ts', { regex = true })<CR>", opts)
keymap("n", "<leader>orr", "<cmd>:lua require('nvim-quick-switcher').find('.+reducer.ts|.+repository.ts', { regex = true })<CR>", opts)
```

## Personal Motivation
Many moons ago, as a sweet summer child, I used VS Code with an extension called "Angular Switcher".
Angular switcher enables switching to various file extensions related to the current component.

I wanted to take that idea and make it work for many frameworks or file extensions

I currently use nvim-quick-switcher on a daily basis for Svelte / Svelte-Kit, Angular Components, Tests, Stylesheets, Lua util files, and Redux-like files.

## Alternatives
- [projectionist](https://github.com/tpope/vim-projectionist)
