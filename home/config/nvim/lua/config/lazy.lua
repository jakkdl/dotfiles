-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"


-- Only check for updates on startup once a week
--local function should_check_updates()
--  local state_file = vim.fn.stdpath("state") .. "/lazy/last_update"
--  local week_in_seconds = 7 * 24 * 60 * 60
--
--  local file = io.open(state_file, "r")
--  if not file then
--    file = io.open(state_file, "w")
--    file:write(tostring(os.time()))
--    file:close()
--    return true
--  end
--
--  local last_check = tonumber(file:read("*all"))
--  file:close()
--
--  if os.time() - last_check > week_in_seconds then
--    file = io.open(state_file, "w")
--    file:write(tostring(os.time()))
--    file:close()
--    return true
--  end
--
--  return false
--end

local function should_check_updates()
  local state_file = vim.fn.stdpath("state") .. "/lazy/last_update"
  local period = 1 * 24 * 60 * 60

  local stat = vim.loop.fs_stat(state_file)
  if not stat then
    io.open(state_file, "w"):close()
    return true
  end

  if os.time() - stat.mtime.sec > period then
    vim.loop.fs_utime(state_file, os.time(), os.time())
    return true
  end

  return false
end

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "gruvbox" } },
  -- automatically check for plugin updates
  checker = {
      enabled = should_check_updates(),
  },
})
