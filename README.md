# Nvim Quick Switcher

**Work in Progress: Plugin is fragile & not easy to configure**

## What is it
Switch (current buffer) based on context 
- ticket.component.ts -> ticket.component.html
- ticket.component.scss -> ticket.component.html
- ticket.effects.ts -> tickets.store.ts
- etc

## Example Setup
Given the following setup:

on `<leader>bb` key-press,
if `ticket.store.ts` was in the current buffer
`ticket.query.ts` would open as the current buffer

on `<leader>bb` key-press,
if `ticket.component.ts` or `ticket.component.scss` was in the current buffer
`ticket.component.html` would open as the current buffer

```lua
local rxLikeMatches = {'query', 'store'}
local componentMatches = {'component'}
require("nvim-quick-switcher").setup({
  {
    mapping = "<leader>bb",
    matchers = {
      { matches = rxLikeMatches, suffix = 'query.ts' },
      { matches = componentMatches, suffix = 'component.html'}
    }
  },
  {
    mapping = "<leader>nn",
    matchers = {
      { matches = rxLikeMatches, suffix = 'store.ts' },
      { matches = componentMatches, suffix = 'component.scss'}
    }
  }
})
```

## Example Ad Hoc Key Map
**TODO: Make these easier to write**
```
nnoremap <silent> <leader>ww :lua require("nvim-quick-switcher").switchTo({ rxLike = {  matches = {'query', 'store'}, suffix = 'query.ts' }, componentLike = { matches = {'component'}, suffix = 'component.html'}})<CR>
```
