# topline.nvim

**Simple and minimal tabline as a replacement to inbuilt one with icon and mouse support**

Mouse support is only when underlying terminal emulator and neovim supports it

- Checkout [bottomline.nvim](https://github.com/mnjm/bottomline.nvim) for statusline plugin

### Demo
![Demo Gif](https://github.com/mnjm/github-media-repo/blob/a1918ab62ca1f8ef95bb2ada9bc4ce44c5152200/topline.nvim/demo.gif)
### Screenshots
![1.png](https://github.com/mnjm/github-media-repo/blob/6a351736a158012ff40b008895c2a308e5aa4bdb/topline.nvim/1.png)
![2.png](https://github.com/mnjm/github-media-repo/blob/6a351736a158012ff40b008895c2a308e5aa4bdb/topline.nvim/2.png)

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
