-- IT WORKS!!!!
-- it requires xdg-desktop-portal-gtk
-- can be manually set with
-- gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

return {
  "f-person/auto-dark-mode.nvim",
  opts = {
    update_interval = 5000,  -- milliseconds
    set_dark_mode = function()
      vim.api.nvim_set_option_value("background", "dark", {})
    end,
    set_light_mode = function()
      vim.api.nvim_set_option_value("background", "light", {})
    end,
  },
}
