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
```vimscript
nnoremap <silent> <leader>oc :lua require('nvim-quick-switcher').toggle('cpp', 'h')<CR>
```

### Advanced Options
`switch` optionally takes an `options` parameter.

```lua
{
  split = 'vertical'|'horizontal'|nil -- nil is default
  size = 100 -- units=columns|rows default is '' which returns 50/50 split
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

