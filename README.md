# topline.nvim

**Simple and minimal tabline as a replacement to inbuilt one with icon and mouse support**

Mouse support is only when underlying terminal emulator and neovim supports it

- Checkout [bottomline.nvim](https://github.com/mnjm/bottomline.nvim) for statusline plugin

![Demo Gif](https://github.com/mnjm/github-media-repo/blob/15e5a965e38797ae56aa2006ee32118c7f881217/topline.nvim/demo.gif)
![Demo SS](https://github.com/mnjm/github-media-repo/blob/15e5a965e38797ae56aa2006ee32118c7f881217/topline.nvim/ss1.png)
![Demo SS](https://github.com/mnjm/github-media-repo/blob/15e5a965e38797ae56aa2006ee32118c7f881217/topline.nvim/ss2.png)

## Installation

```
mnjm/topline.nvim
```
Install with your favorite plugin manager

Optional dependency for icon support - [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)

### Optional

You can force nvim to show tabline always by 

**In lua**
```lua
vim.o.showtabline = 2
```
(or)

**In vim**
```vim
set showtabline=2
```

### Default configuration

```lua
seperator = { pre = '', post = '' },
enable_icons = true,
max_fname_len = 25,     -- max file name len
close_icon = "[x]",
highlights = {          -- highlights
  TopLine         = { link = 'TabLine' },               -- tab title
  TopLineSel      = { link = 'TabLineSel' },            -- tab title [Focused]
  TopLineFill     = { link = 'TabLineFill' },           -- filler
  TopLineClose    = { link = 'TabLineSel' },            -- close button
}
```
You can override default config by passing custom config to setup call, for ex

```lua
require('bottomline.nvim').setup({
  seperator = { pre = '', post = '' },
  -- seperator = { pre = '', post = '' },
  close_icon = " 󰅘 ",
  highlights = {
    TopLineClose = { fg = "#d70000", bg = "#000000" },
})
```
