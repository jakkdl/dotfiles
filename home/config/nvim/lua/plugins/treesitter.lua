return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").install({ "python", "rst" })
        vim.api.nvim_create_autocmd("FileType", {
            pattern = { "python", "rst" },
            callback = function() vim.treesitter.start() end,
        })
    end
}
