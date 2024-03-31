# topline.nvim

** Simple and minimal tabline as a replacement to inbuilt one with icon and mouse support **
Mouse support is only when underlying terminal emulator and neovim supports it

## Screenshots

TODO:

## Installation

```
mnjm/topline.nvim
```
Install with your favorite plugin manager
Optional dependency for icon support - [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons)

### Default configuration

```lua
default_config = {
    seperator = ' ',
    seperator_highlight = nil,
    enable_icons = true,
    tab_label_len = 15,
}
```
You can pass sub-table with custom configurations to setup call, for ex

```lua
require('bottomline.nvim').setup({
    seperator_highlight = {fg = "#ffffff", bg="#262626", gui=nil},
})
```
