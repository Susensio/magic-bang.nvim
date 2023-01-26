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
  default = "/bin/bash"
}


local function isempty(s)
  return s == nil or s == ""
end

local function sort(list)
  table.sort(list,
    function (a, b) return string.upper(a) < string.upper(b) end)
end

local function filter(list, pattern)
  -- Only match whole words
  pattern = "%f[%a]" .. string.lower(pattern)
  return vim.tbl_filter(
    function (item)
      return string.find( string.lower(item), pattern ) and true or false
    end,
    list)
end

local function dirname_in_path()
  paths = vim.split(vim.env.PATH, ':')
  -- TODO: this may not always work in older nvim versions
  dirname = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
  return vim.tbl_contains(paths, dirname)
end

local function exists_shebang()
  first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
  if first_line:sub(1,2) == "#!" then
    return true
  end
end

local function get_shebang(ext)
  -- Get extension from filename if not provided
  if isempty(ext) then
    ext = vim.fn.expand("%:e")
  end
  
  -- Fallback to default if no extension
  local shebang = nil
  if isempty(ext) then
    shebang = M.config.default
  else
    shebang = M.config.bins[ext]
  end

  return shebang
end

local magicbang_grp = vim.api.nvim_create_augroup("magic-bang", { clear = true })

M.insert_shebang = function(shebang)

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
    
    -- Detect filetype
    vim.cmd("filetype detect")
    -- new neovim syntax
    -- vim.filetype.match({ buf=vim.api.nvim_get_current_buf() })

    -- Make file executable on write
    if M.config.executable then
      vim.api.nvim_create_autocmd(
        "BufWritePost",
        { pattern = "*",
          callback = function()
            if exists_shebang() then
              vim.cmd(":!chmod u+x %")
            end
          end,
          desc = "Make file executable if shebang still exists",
          group = magicbang_grp
        }
      )
    end
  end
end


M.setup = function(user_config)
  M.config = vim.tbl_deep_extend("force", M.config, user_config or {})
  
  if M.config.automatic and dirname_in_path() then
    vim.api.nvim_create_autocmd(
      "BufNewFile",
      { pattern = "*",
       callback = function() 
          shebang = get_shebang()
          M.insert_shebang(shebang)
        end,
       desc = "Auto insert shebang when needed",
       group = magicbang_grp
      }
    )
  end

  if M.config.command then
    vim.api.nvim_create_user_command(
      "Bang",
      function(opts)
        shebang = opts.args
        if isempty(shebang) then
          shebang = get_shebang()
        end
        M.insert_shebang(shebang)
      end,
      { desc = "Insert shebang and make executable",
       nargs = "?",
       complete = function(arg_lead) 
         local bangs = vim.tbl_values(M.config.bins)
         sort(bangs)
         return filter(bangs, arg_lead)
       end,
      }
    )
  end
end


return M
