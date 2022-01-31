# Nvim Quick Switcher
Create mappings to quickly navigate to other files based on the current file name. Written in Lua.

![demo](https://user-images.githubusercontent.com/14320878/151885059-5a1f1773-6e7c-469e-9866-f615cc688957.gif)

## Features
- 🦕 Switch to files with common prefix (example: "tasks"):
  - `tasks.component.ts` --> `tasks.component.html`
  - `tasks.component.ts` --> `tasks.component.scss`
- 🦎 Toggle between file extensions
  - `tasks.cpp` <--> `tasks.h`
  - `tasks.html` <--> `tasks.css`
- 🐙 Switch to files with different suffix, not just file extension
  - `tasks.component.ts` --> `tasks.module.ts`
  - `tasks.component.ts` --> `tasks.component.spec.ts`
  - `tasks.query.ts` --> `tasks.store.ts`
- 🔭 Use a single mapping to navigate to a file based on context
  - `<leader>oo` (Example mapping) 
    - If in `tasks.query.ts` --> `tasks.store.ts`
    - If in `tasks.component.ts` --> `tasks.component.html`

## Installation
Vim-plug -- See "Example Configuration" Below. This plugin does nothing without explicit setup.
```vimscript
Plug 'Everduin94/nvim-quick-switcher'

lua << EOF
  require("nvim-quick-switcher").setup({}) 
EOF
```

Packer
```lua
use {
  "Everduin94/nvim-quick-switcher",
}

require("nvim-quick-switcher").setup({}) 
```

## Example Configuration
nvim-quick-switcher must be explicitly configured. It doesn't assume any
defaults or run setup without being explicitly called.

How you use nvim-quick-switcher is entirely up to you. The below configuration
gives various examples of how you may want to use it (demonstrated in video above)

```lua
local rxLikeMatches = {'query', 'store', 'effects', 'actions'}
local componentMatches = {'component', 'module'}

require("nvim-quick-switcher").setup({
  -- Allows swapping between .cpp and .h files (e.g. Node.cpp <-> Node.h)
  mappings = {
    {
      mapping = '<leader>mm',
      matchers = {
        { matches = {'cpp'}, suffix = 'h' },
        { matches = {'h'}, suffix = 'cpp' },
      }
    },
    -- oo, oi, and ou work together to allow you to navigate to any file while in:
      -- ts|scss|html
      -- query|effects|store
    {
      mapping = "<leader>oo",
      matchers = {
        { matches = rxLikeMatches, suffix = 'query.ts' },
        { matches = componentMatches, suffix = 'component.html'}
      }
    },
    {
      mapping = "<leader>oi",
      matchers = {
        { matches = rxLikeMatches, suffix = 'effects.ts' },
        { matches = componentMatches, suffix = 'component.scss'}
      }
    },
    {
      mapping = "<leader>ou",
      matchers = {
        { matches = rxLikeMatches, suffix = 'store.ts' },
        { matches = componentMatches, suffix = 'component.ts'}
      }
    },
    -- Matches can match longer suffix than the file you're in
     -- e.g. component.html -> component.spec.ts, is valid
    {
      mapping = "<leader>oy",
      matchers = {
        { matches = componentMatches, suffix = 'component.spec.ts'}
      }
    },
    -- Mapping/Matchers can be 1:1, you don't have to put many matches on a single keybind
    {
      mapping = "<leader>oa",
      matchers = {
        { matches = rxLikeMatches, suffix = 'actions.ts'}
      }
    },
    {
      mapping = "<leader>op",
      matchers = {
        { matches = rxLikeMatches, suffix = 'module.ts'},
        { matches = componentMatches, suffix = 'module.ts'}
      }
    },
  }
})
```

**Configuration Properties / Additional Info**

- **mapping**: A vim mapping as a string
- **matchers**: An array of `{ matches, suffix }`
- **matches**: An array of strings that will perform an == match on the current file name split by `.`
  - `{'query', 'store'}` could match `tickets.store.ts` or `tickets.query.ts`
  - but **not** `tickets-query.ts` or `tickets-store.ts`
- **suffix**: A string appended to the prefix. Caveat, the `.` is auto appended
  - If the desired outcome is `something.component.spec.ts` the suffix should be `component.spec.ts`

## Usage
All mappings in the configuration are bound to normal mode. 
To use, while in a file that suffices one of the "matches" defined, invoke it's corresponding mapping.
A new or existing buffer should open with the same prefix + the suffix defined by that mapping.

**Ad Hoc Config**

If desired, matchers can be passed directly to the switchTo function.
```
nnoremap <silent> <leader>ww :lua require("nvim-quick-switcher").switchTo({ { matches = {'query', 'store'}, suffix = 'query.ts' }, { matches = {'component'}, suffix = 'component.html'} })<CR>
```

## TODO
- Collision matches don't have a sane way to resolve
  - e.g. if `.module.ts` could go to `.component.css` or `.effects.ts` the resulting file is random
  - I'd like to check if one or the other exists first.
- Config validation: If a bad config is passed in; no sane output for help

## Personal Motivation
Many moons ago, as a sweet summer child, I used VS Code with an extension called "Angular Switcher".
Angular switcher enables jumping from various file extensions related to the current component.

I wanted to take that idea and accomplish two things
- Make this work for many frameworks or file extensions
- Assign 1 mapping for multiple frameworks / extensions.

I currently use nvim-quick-switcher on a daily basis for Angular Components and Redux-like files.

For example, based on my current context.
- oo --> html or query
- oi --> css or effects
- ou --> ts or store

1 binding, opens different files, based on context. Instead of assigning multiple bindings for every context.


