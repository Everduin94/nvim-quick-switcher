# Nvim Quick Switcher

**Work in Progress: Plugin is fragile and may not cover specific cases**

## What is it
Configure mappings to switch file / current buffer based on context (file name)
- ticket.component.ts --> ticket.component.html
- ticket.component.scss --> ticket.component.html
- ticket.effects.ts --> tickets.store.ts
- window-helper.cpp <--> window-helper.hpp

## Example Setup
(1 to many) matchers are assigned to a single mapping.
Meaning, based on the context of the current buffer / file name,
a single mapping can have multiple outcomes

Given the following setup:

```lua
-- Assign matches to variables for reusability
local rxLikeMatches = {'query', 'store'}
local componentMatches = {'component'}

-- invoke setup with config
require('nvim-quick-switcher').setup({
    mappings = {
      {
        mapping = '<leader>bo',
        matchers = {
          { matches = rxLikeMatches, suffix = 'query.ts' },
          { matches = componentMatches, suffix = 'component.html'}
        }
      },
      {
        mapping = '<leader>bi',
        matchers = {
          { matches = rxLikeMatches, suffix = 'store.ts' },
          { matches = componentMatches, suffix = 'component.scss'}
        }
     }
   }
})
```

on `<leader>bo` key-press,
if `ticket.store.ts` was in the current buffer
`ticket.query.ts` would open as the current buffer

on `<leader>bo` key-press,
if `ticket.component.ts` or `ticket.component.scss` was in the current buffer
`ticket.component.html` would open as the current buffer

Note, as long as the match is found anywhere in the file name, it will attempt to open 
a file with the same prefix (in our example, *ticket*) + the given suffix.
- Matches only look for whole words (including optional `-` and `_`)
- So writing a matcher such as `component.spec` will not net any results
- However, the suffix can be as specific as necessary.
  - Example. `suffix: 'component.spec.ts'` is valid and will navigate to `prefix.component.spec.ts`

Caveat for suffix. The first period after the prefix is automatically appended.
So suffix should be written as `something.ts` not `.something.ts`


## Example Ad Hoc Key Map
**TODO: Make these easier to write**
```
nnoremap <silent> <leader>ww :lua require("nvim-quick-switcher").switchTo({ { matches = {'query', 'store'}, suffix = 'query.ts' }, { matches = {'component'}, suffix = 'component.html'} })<CR>
```

## Using as a file extension toggle 
Sometimes you may not care about a prefix, but the file extension itself.

```lua
require('nvim-quick-switcher').setup({
    mappings = {
      {
        mapping = '<leader>bb',
        matchers = {
          { matches = { 'cpp' }, suffix = 'hpp' },
          { matches = { 'hpp' }, suffix = 'cpp'}
        }
      }
   }
})
```
As an example: window-helper.cpp <--> window-helper.hpp

## Terminology
- prefix: this is the first word in the file name; window-helper.component.ts
  - the prefix would be "window-helper"
- **suffix**: this is anything that comes after the prefix; if we had a complex file name like: window-helper.component.spec.ts
  - the suffix would be component.spec.ts
- **matches**: nvim-quick-switcher only does basic equals check on a single word. Given { 'component' }
  - this would match something.component.ts and something-else.component.spec.ts
- **matchers**: an array of {matches, suffix}
- **mapping**: a vim mapping as a string
- **mappings**: an array of {mapping, matchers}

## Motivation
**The first pattern**

Many moons ago, as a sweet summer child, I used VS Code with an extension called "Angular Switcher".
Angular is known for creating about 18 files for a single component (kidding, it's like 4ish).
All of the files contain the same prefix (The name of component), but different file extensions.
e.g. something.component.ts, something.component.html, something.component.scss.

The Angular Switcher could assign mappings to switch to .ts,.html,.css for the currently open component;
creating a very fast way to switch between files related to the component.

Not only did I want this ability in vim. But I wanted to be able to do this for
other patterns in other frameworks. And I wanted to be able to use 1 set of bindings to do it all.

**Another pattern emerges**

Akita, a Redux-like framework for Angular, commonly creates numerous files for 1 data type.
something.store.ts, something.query.ts, something.effects.ts, etc...

**Bringing it all together**

Instead of creating separate mappings to "go to query" and "go to html" and "go to X". 
I wanted 1 binding to do what made sense, based on my current buffer.
Thus, nvim-quick-switcher is quite verbose to configure. But it allows for
a single mapping to switch to multiple different suffix, based on (current buffer) file name.

## How I use nvim quick switcher
TODO: Add my config and explanation
