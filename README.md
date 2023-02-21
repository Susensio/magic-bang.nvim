# 🪄 #Magic Bang! 

A simple Neovim plugin written in pure Lua that automagically inserts a shebang line
when needed and makes the file executable.


## How it works

![sample](https://user-images.githubusercontent.com/11474625/214789323-bbb3e8b7-d8c1-4627-a556-833c426dd3d3.gif)


It checks if the current file is in `$PATH` and reads its extension to insert the corresponding shebang.
If no extension is present, default shebang is used.

On exit, the file is made executable _only_ if the shebang is still present.

`:Bang` command adds a shebang manually.


## Installation

### [lazy](https://github.com/folke/lazy.nvim) with lazyloading
```lua
{
  "susensio/magic-bang.nvim",
  config = true,
  event = "BufNewFile",
  cmd = "Bang",
}
```

### [packer](https://github.com/wbthomason/packer.nvim)
```lua
use {
    "susensio/magic-bang.nvim",
    config = function() require("magic-bang").setup() end
}
```

### [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug "susensio/magic-bang.nvim"
lua require("magic-bang").setup()
```



## Usage

If a new file is in `$PATH`, the `:Bang` command is fired automatically. A manual user command is provided `:Bang [<binary>]` with an optional `binary` argument, usefull when editing previously created files or source files without extension.
```
-- Try to set shebang based on extension, or insert default shebang
:Bang

-- Force specific shebang by declaring binary
:Bang python3
```


## Customization

You can set custom shebangs or override defaults in `setup` with `bins = { extension = binary }`, using either a binary command (which will be resolved with `/usr/bin/env`) or a full path:

```lua
require("magic-bang").setup({
    bin = {
        ksh = "/usr/bin/ksh",
        py = "python3.11",
        scala = nil
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
    automatic = true,         -- insert shebang on new file when in $PATH
    command = true,           -- define Bang user command
    executable = true,        -- make file executable on exit
    default = "/bin/bash"     -- default shebang for `:Bang` without args
}
```

## Acknowledgments

To [samirettali](https://github.com/samirettali) for his [shebang.nvim](https://github.com/samirettali/shebang.nvim) that inspired this pluggin.


## FAQ

**Q:** How does it differ from forked [samirettali/shebang.nvim](https://github.com/samirettali/shebang.nvim)?

**A:** First, it only makes a file executable if the shebang is still present on exit. This prevent _false positives_. Second, a `:Bang` user command can manually add a shebang, helping with _false negatives_.

