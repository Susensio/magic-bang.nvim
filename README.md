# shebang.nvim

A simple Neovim plugin written in Lua that automatically inserts a shebang line
when editing a new file and make it executable.

## Installation

### [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug "susensio/shebang.nvim"
lua require("shebang").setup()
```

### [packer](https://github.com/wbthomason/packer.nvim)
```lua
use {
    "susensio/shebang.nvim",
    config = function() require("shebang").setup() end
}
```


## Usage

If a file extension is present, the pluggin works automatically. A manual user command is provided `:Bang [<ext>]` with an optional extension argument, usefull when editing previously created files or source files without extension.
```
-- Try to set shebang based on extension
:Bang

-- Force specific shebang by declaring extension
:Bang py
```


## Customization

You can set custom shells by setting the global variables `shebang_shells` and
`shebang_commands`:

### vimscript
```VimL
let g:shebang_commands = { "py": "/usr/bin/python3.9" }
let g:shebang_shells = { "py": "python3.9" }
```

### lua
```lua
vim.g.shebang_commands = {
    py = "/usr/bin/python3.9"
}
vim.g.shebang_shells = {
    py = "python3.9"
}
```

The difference between the two is that the executables in `shebang_shells` have
must be in the `PATH` environment variable, while the in `shebang_commands` you
can use full paths to the executable.
