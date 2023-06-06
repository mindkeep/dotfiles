-- init lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
	spec = {
		{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
		--{ import = "lazyvim.plugins.extras.coding.copilot" },
		{ import = "lazyvim.plugins.extras.lang.json" },
		{ import = "lazyvim.plugins.extras.lang.go" },
		{ import = "plugins" },
	},
	defaults = {
		lazy = true, -- lazy load everything
		version = false, -- always use the latest git commit
	},
	checker = { enabled = true }, -- automatically check for plugin updates
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				-- "matchit",
				-- "matchparen",
				-- "netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
	ui = {
		border = "rounded",
	},
})
