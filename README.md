# [TopLine.nvim](https://github.com/mnjm/topline.nvim)

**A tabline plugin as a replacement to inbuilt one with icon and mouse support**

![Demo Gi](https://github.com/mnjm/github-media-repo/blob/main/topline.nvim/demo.gif)
![Demo SS](https://github.com/mnjm/github-media-repo/blob/main/topline.nvim/ss1.png)
![Demo SS](https://github.com/mnjm/github-media-repo/blob/main/topline.nvim/ss2.png)

**My other plugins**
- [BottomLine.nvim](https://github.com/mnjm/bottomline.nvim) - Statusline plugin
- [WinLine.nvim](https://github.com/mnjm/winline.nvim) - WinLine plugin

## Installation

### vim-plug
```vim
Plug 'mnjm/topline.nvim'
" Optional dependency for icons
Plug 'nvim-tree/nvim-web-devicons'
```
### packer.nvim
```lua
use {
    'mnjm/topline.nvim',
    -- optional dependency for icons 
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
}
```
### lazy.nvim
```lua
{
    'mnjm/topline.nvim'
    dependencies = { 'nvim-tree/nvim-web-devicons' }
}
```
## Setup
To start topline, add below line in your neovim config
```lua
require("topline").setup()
```
### Customization
You can pass custom config to override default configs to setup call, for ex
```lua
require('topline').setup({
  enable = true,
  -- seperator = { pre = '', post = '' },
  -- seperator = { pre = '', post = '' },
  seperator = { pre = '',  post = '' },
  close_icon = " 󰅘 ",
  highlights = {
    TopLineClose = { fg = "#d70000", bg = "#000000" },
  },
})
```
Available configuration options
```lua
require('topline').setup({
  enable = true,
  seperator = { pre = '', post = '' },
  enable_icons = true,
  max_fname_len = 25,     -- max file name len
  close_icon = "[x]",
  highlights = {          -- highlights
    TopLine         = { link = 'TabLine' },               -- tab title
    TopLineSel      = { link = 'TabLineSel' },            -- tab title [Focused]
    TopLineFill     = { link = 'TabLineFill' },           -- filler
    TopLineClose    = { link = 'TabLineSel' },            -- close button
  },
})
```
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
