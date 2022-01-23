# Nvim Quick Switcher
Create mappings to quickly switch-to/open file based on file name in current buffer. Written in Lua.

https://user-images.githubusercontent.com/14320878/147480710-a7359fe2-38dd-4d75-96d2-e6cf13a90a15.mp4

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
  mappings = {
    {
      mapping = '<leader>mm',
      matchers = {
        { matches = {'cpp'}, suffix = 'h' },
        { matches = {'h'}, suffix = 'cpp' },
      }
    },
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
    {
      mapping = "<leader>oy",
      matchers = {
        { matches = componentMatches, suffix = 'component.spec.ts'}
      }
    },
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

**Configuration Properties**

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

If desired, matchers can be passed directly to the switchTo function
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

This way I could make a mental map. If the beginning of my 
mapping to start the switch was always `<leader>o`, then I could
mentally map keys to concepts instead of specific actions.

For example, based on my current context.
- oo --> html or query
- oi --> css or effects
- ou --> ts or store

As I learn of new frameworks or patterns where quick switching is
applicable. I can add them to my existing config and mental model 
instead of creating a whole new set of mappings I have to remember.

