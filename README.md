# Nvim Quick Switcher
Quickly navigate to related/alternate files/extensions based on the current file name. Written in Lua.

![demo-2](https://user-images.githubusercontent.com/14320878/152060031-cec37a34-b1f8-4812-9758-e43a04f044a8.gif)

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
- 🐒 Find files by Wilcard or Regex
  - `tasks.ts` --> `tasks.spec.ts` | `tasks.test.ts` 
  - `tasks.ts` --> `tasks.css` | `tasks.scss` | `tasks.sass`
  - `/tasks.components.ts` --> `state/tasks.query.ts` 
  - `state/tasks.query.ts` --> `../tasks.component.ts`
  - `controller.lua` --> `controller_spec.lua`
  - `controller-util.lua` --> `controller-service.lua`

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

Switcher has 3 functions. `switch` and `toggle` are the most straightforward and the
best option to get started. For more examples, see `Recipes`

### ➡️ Switch
*Gets "prefix" of file name, switches to `prefix`.`suffix`*

`require('nvim-quick-switcher').switch('component.ts')`
- `ticket.component.html` --> `ticket.component.ts`

#### Options
```lua
{
  split = 'vertical'|'horizontal'|nil -- nil is default
  size = 100 -- # of columns | rows. default is 50% split
}
```

### 🔄 Toggle
*Toggles `prefix`.`suffix`, based on current suffix / file extension*

`require('nvim-quick-switcher').toggle('cpp', 'h')`
- `node.cpp` --> `node.h`
- `node.h` --> `node.cpp`

### 🔍 Find 
*Uses gnu/linux `find` & `grep` to find file and switch to `prefix` `result`*

`require('nvim-quick-switcher').find('*query*')`
- Allows wild cards, i.e. first argument is search parameter for gnu/linux find
- `ticket.component.ts` --> `ticket.query.ts`

`require('nvim-quick-switcher').find('.+css|.+scss|.+sass', { regex = true })`
- Uses find, then filters via grep regex, i.e. first argument is regex
- `ticket.component.ts` --> `ticket.component.css|scss|sass`
- When using backslash, may have to escape via `\\`

If multiple matches are found will prompt UI Select.
- You can use options like `prefix` or `regex` to make your searches more specific.


If no results are found, will search backwards one directory, see `reverse`

#### Options 
```lua
{
  split = 'vertical'|'horizontal'|nil
  size = 100 
  regex = false, -- true uses perl regex. results will be filters by `prefix*`
  maxdepth = 2, -- directory depth 
  reverse = true, -- false will disable reverse search when no results are found
  path = nil, -- overwrite path (experimental).
  prefix = 'default', -- full: stop at last period. short: stop at first _ or -. default: stop at first period.
  regex_type = 'E' -- default regex extended. See grep for types.
}
```

## Recipes (My Binds)
*My configuration for nvim-quick-switcher. Written in Lua*

```lua
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Tests
keymap("n", "<leader>ot", "<cmd>:lua require('nvim-quick-switcher').find('.+test|.+spec', { regex = true, prefix='full' })<CR>", opts)

-- Redux-like
-- Using find over switch to search with depth incase outside a redux-like folder "/state"
keymap("n", "<leader>oe", "<cmd>:lua require('nvim-quick-switcher').find('*effects*')<CR>", opts)
keymap("n", "<leader>oa", "<cmd>:lua require('nvim-quick-switcher').find('*actions*')<CR>", opts)
keymap("n", "<leader>oq", "<cmd>:lua require('nvim-quick-switcher').find('*query*')<CR>", opts)
keymap("n", "<leader>ow", "<cmd>:lua require('nvim-quick-switcher').find('*store*')<CR>", opts)

-- Stylesheets
keymap("n", "<leader>oi", "<cmd>:lua require('nvim-quick-switcher').find('.+css|.+scss|.+sass', { regex = true, prefix='full' })<CR>", opts)

-- Angular
-- Using find over switch to look backwards incase in a redux-like folder "/state"
keymap("n", "<leader>os", "<cmd>:lua require('nvim-quick-switcher').find('.service.ts')<CR>", opts)
keymap("n", "<leader>ou", "<cmd>:lua require('nvim-quick-switcher').find('.component.ts')<CR>", opts)
keymap("n", "<leader>oo", "<cmd>:lua require('nvim-quick-switcher').find('.component.html')<CR>", opts)
keymap("n", "<leader>op", "<cmd>:lua require('nvim-quick-switcher').find('.module.ts')<CR>", opts)

-- Switches for - or _ e.g. controller-util.lua
keymap("n", "<leader>ol", "<cmd>:lua require('nvim-quick-switcher').find('*util.*', { prefix='short' })<CR>", opts)

-- Legacy
-- keymap("n", "<leader>ou", "<cmd>:lua require('nvim-quick-switcher').switch('component.ts')<CR>", opts)
-- keymap("n", "<leader>oo", "<cmd>:lua require('nvim-quick-switcher').switch('component.html')<CR>", opts)
-- keymap("n", "<leader>oi", "<cmd>:lua require('nvim-quick-switcher').switch('component.scss')<CR>", opts)
-- keymap("n", "<leader>op", "<cmd>:lua require('nvim-quick-switcher').switch('module.ts')<CR>", opts)
-- keymap("n", "<leader>ot", "<cmd>:lua require('nvim-quick-switcher').switch('component.spec.ts')<CR>", opts)
-- keymap("n", "<leader>ovu", "<cmd>:lua require('nvim-quick-switcher').switch('component.ts', { split = 'vertical' })<CR>", opts)
-- keymap("n", "<leader>ovi", "<cmd>:lua require('nvim-quick-switcher').switch('component.scss', { split = 'vertical' })<CR>", opts)
-- keymap("n", "<leader>ovo", "<cmd>:lua require('nvim-quick-switcher').switch('component.html', { split = 'vertical' })<CR>", opts)
-- keymap("n", "<leader>oc", "<cmd>:lua require('nvim-quick-switcher').toggle('cpp', 'h')<CR>", opts)
```

## Personal Motivation
Many moons ago, as a sweet summer child, I used VS Code with an extension called "Angular Switcher".
Angular switcher enables switching to various file extensions related to the current component.

I wanted to take that idea and make it work for many frameworks or file extensions

I currently use nvim-quick-switcher on a daily basis for Angular Components, Tests, Lua util files, and Redux-like files.

## Alternatives
- [projectionist](https://github.com/tpope/vim-projectionist)

