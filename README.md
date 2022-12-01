# shebang.nvim

A simple Neovim plugin written in Lua that automatically inserts a shebang line
when editing a new file and makes it executable.

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

You can set custom shebangs or override defaults in `setup` with `bins = { extension = binary }`, using either a binary command (which will be resolved with `/usr/bin/env`) or a full path:

```lua
require("shebang").setup({
    bin = {
        py = "python3.11",
        ksh = "/usr/bin/ksh"
    }
})
```

Default options are:
```lua
{
    bins = {
        awk = "awk",
        hs = "runhaskell",
        jl = "julia",
        lua = "lua",
        m = "octave",
        mak = "make",
        php = "php",
        pl = "perl",
        py = "python3",
        r = "Rscript",
        rb = "ruby",
        scala = "scala",
        sh = "bash",
        tcl = "tclsh",
        tk = "wish",
    },
    automatic = true,       -- insert shebang on new file
    command = true,         -- define Bang user command
    executable = true,      -- make file executable on exit
}
```
