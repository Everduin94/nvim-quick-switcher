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

## Installation
Vim-plug 
```vimscript
Plug 'Everduin94/nvim-quick-switcher'
```

Packer
```lua
use {
  "Everduin94/nvim-quick-switcher",
}
```

## Example Usage

Quick Switcher provides two functions

`switch(suffix)` -- provided a string, switches to `prefix`.`suffix`
- For context, `prefix`, is the first word before the first `.`
- Examples:
  - In `index.ts`, `switch('html')`, will return `index.html`
  - In `tasks.component.ts`, `switch('component.html')`, will return `tasks.component.html`
  - In `tasks.query.ts`, `switch('store.ts')`, will return `tasks.store.ts`

`toggle(suffixOne, suffixTwo)` -- provided two strings, toggles between `prefix`.`suffixOne`|`prefix`.`suffixTwo`
- Examples:
  - In `index.ts`, `toggle('html', 'ts')`, will return `index.html`
  - In `index.html`, `toggle('html', 'ts')`, will return `index.ts`
  - In `node.cpp`, `toggle('cpp', 'h')`, will return `node.h`
  - In `node.h`, `toggle('cpp', 'h')`, will return `node.cpp`

### Switch
```vimscript
nnoremap <silent> <leader>oc :lua require('nvim-quick-switcher').toggle('cpp', 'h')<CR>
```

### Toggle
nnoremap <silent> <leader>oc :lua require('nvim-quick-switcher').toggle('cpp', 'h')<CR>
nnoremap <silent> <leader>oo :lua require('nvim-quick-switcher').find('*query*')<CR>
nnoremap <silent> <leader>ot :lua require('nvim-quick-switcher').find('*spec*')<CR>
```
#### Regex
*Currently uses `extended` regex by default. Must escape backslashes. Returns ui select if multiple results*
*Will search backwards 1 directory if no results found, useful for moving in and out of a folder*
*Pulls all results equal to `prefix*` then further filters via regex*
```vimscript
nnoremap <silent> <leader>ot :lua require('nvim-quick-switcher').find('.+spec\\.|.+test\\.', { regex = true })<CR>
nnoremap <silent> <leader>oc :lua require('nvim-quick-switcher').find('.+css|.+scss|.+sass', { regex = true })<CR>
nnoremap <silent> <leader>oq :lua require('nvim-quick-switcher').find('*query*')<CR>
>>>>>>> 8aee1b6 (Fix regex for mac, added config option)
```

### Advanced Options
`switch` optionally takes an `options` parameter.

```lua
{
  split = 'vertical'|'horizontal'|nil -- nil is default
  size = 100 -- units=columns|rows default is '' which returns 50/50 split
  regex = false, -- true uses perl regex. results will be filters by `prefix*`
  maxdepth = 2, -- directory depth 
  reverse = true, -- false will disable reverse search when nothing is found
  path = nil, -- overwrite path (experimental).
  
  -- if 'full' tasks.component.ts --> `tasks.component` instead of `tasks`
   -- i.e. stop at last period
  -- if 'short' tasks-util.lua or tasks_util.lua --> `tasks` instead of `tasks-util` or `tasks_util`
   -- i.e. stop at first -|_
  prefix = 'default', 
  regex_type = 'E' -- default regex extended. See grep for types.
}
```

```vimscript
" Open a vertical split 50/50
nnoremap <silent> <leader>ou :lua require('nvim-quick-switcher').switch('component.ts', { split = 'vertical' })<CR>

" Open a horizontal split, with a size of 80 rows
nnoremap <silent> <leader>ou :lua require('nvim-quick-switcher').switch('component.ts', { split = 'horizontal', size = 80 })<CR>

" Open a vertical split, with a size of 80 columns
nnoremap <silent> <leader>ou :lua require('nvim-quick-switcher').switch('component.ts', { split = 'vertical', size = 80 })<CR>
```

## Personal Motivation
Many moons ago, as a sweet summer child, I used VS Code with an extension called "Angular Switcher".
Angular switcher enables switching to various file extensions related to the current component.

I wanted to take that idea and make it work for many frameworks or file extensions

I currently use nvim-quick-switcher on a daily basis for Angular Components and Redux-like files.

If there's a framework that's possible to support, but a change is needed to support it. Create an issue.

## Alternatives
- [projectionist](https://github.com/tpope/vim-projectionist)

