local function configure_gruvbox()
    vim.cmd([[colorscheme gruvbox]])
end
return {
	--"morhetz/gruvbox", -- original, does not support setup()
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = configure_gruvbox,
        opts = ...
    }
