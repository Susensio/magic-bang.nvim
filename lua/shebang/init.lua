local M = {}


M.config = {
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
    automatic = true,
    command = true,
    executable = true,
    default = "/bin/sh"
}

local shebang_grp = vim.api.nvim_create_augroup("shebang", { clear = true })

local function exists_shebang()
    first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
    if first_line:sub(1,2) == "#!" then
        return true
    end
end

local function isempty(s)
    return s == nil or s == ""
end

M.insert_shebang = function(ext)
    -- TODO maybe change to check for vim.bo.filetype
    -- Get extension from filename if not provided
    if isempty(ext) then
        ext = vim.fn.expand("%:e")
    end
    
    local shebang = nil
    -- Fallback to default if no extension
    if isempty(ext) then
        shebang = M.config.default
    else
        shebang = M.config.bins[ext]
    end

    if shebang == nil then
        vim.api.nvim_err_writeln("Extension '"..ext.."' was not found in config. No shebang inserted.")
        return 1
    end
    print("AFTER ERROR")

    if shebang ~= nil then
        -- If no full path provided, append env
        if shebang:sub(1,1) ~= "/" then
            shebang = "/usr/bin/env " .. shebang
        end
        shebang = "#!" .. shebang

        vim.api.nvim_win_set_cursor(0, {1,0})

        if exists_shebang() then
            vim.api.nvim_del_current_line()
        end

        vim.api.nvim_put({shebang, ""}, "", false, true)

        if M.config.executable then
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
end


M.setup = function(user_config)
    M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
    
    if M.config.automatic then
        vim.api.nvim_create_autocmd(
            "BufNewFile",
            { pattern = "*.*",
              callback = function() M.insert_shebang() end,
              desc = "Auto insert shebang when needed",
              group = shebang_grp
            }
        )
    end

    if M.config.command then
        vim.api.nvim_create_user_command(
            "Bang",
            function(opts) M.insert_shebang(opts.args) end,
            { desc = "Insert shebang and make executable",
              nargs = "?",
              complete = function(arg_lead) 
                  local exts = vim.tbl_keys(M.config.bins)
                  table.sort(exts)
                  return vim.tbl_filter(
                      function(ext) return vim.startswith(ext, arg_lead) end,
                      exts
                  )

              end,
            }
        )
    end
end


return M
