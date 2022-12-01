local M = {}

local shebang_grp = vim.api.nvim_create_augroup("shebang", { clear = true })

local function get_var(var_name)
  s, v = pcall(function()
    return vim.api.nvim_get_var(var_name)
  end)
  if s then return v else return nil end
end


local function exists_shebang()
    first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    if first_line:sub(1,2) == "#!" then
        return true
    end
end

M.insert_shebang = function(ext)
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
    -- TODO change to check for vim.bo.filetype
    if ext == nil or ext == "" then
        ext = vim.fn.expand("%:e")
    end

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
        vim.api.nvim_win_set_cursor(0, {1,0})

        if exists_shebang() then
            vim.api.nvim_del_current_line()
        end

        vim.api.nvim_put({"#!" .. shebang, ""}, "", false, true)

        vim.api.nvim_create_autocmd(
            "BufWritePost",
            { pattern = "*.*",
              callback = function()
                  if exists_shebang() then
                      vim.cmd(":!chmod u+x %")
                  end
              end,
              desc = "Make file executable if shebang still exists",
              group = shebang_grp
            }
        )
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

    vim.api.nvim_create_user_command(
        "Bang",
        function(opts) M.insert_shebang(opts.args) end,
        { desc = "Insert shebang and make executable",
          nargs = "?",
        }
    )
end


return M
