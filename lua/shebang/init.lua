local M = {}

local function get_var(var_name)
  s, v = pcall(function()
    return vim.api.nvim_get_var(var_name)
  end)
  if s then return v else return nil end
end

local shebang_grp = vim.api.nvim_create_augroup("shebang", { clear = true })

M.insert_shebang = function()
    local shells = {
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
    }

    local ext = vim.fn.expand("%:e")

    local custom_commands = get_var('shebang_commands')
    local custom_shells = get_var('shebang_shells')

    local shebang = nil

    if custom_commands ~= nil and custom_commands[ext] ~= nil then
        shebang = custom_commands[ext]
    elseif custom_shells ~= nil and custom_shells[ext] ~= nil then
        shebang = "/usr/bin/env " .. custom_shells[ext]
    elseif shells[ext] ~= nil then
        shebang = "/usr/bin/env " .. shells[ext]
    end

    if shebang ~= nil then
        vim.cmd [[ autocmd BufWritePost *.* :autocmd VimLeave * :!chmod u+x % ]]
        vim.api.nvim_put({"#!" .. shebang}, "", true, true)
        vim.fn.append(1, '')
        vim.fn.cursor(2, 0)
    end
end


M.setup = function(opt)
    vim.api.nvim_create_autocmd(
        "BufNewFile",
        { pattern = "*.*",
          callback = function() M.insert_shebang() end,
          desc = "Auto insert shebang when needed",
          group = shebang_grp
        }
    )
end



return M
