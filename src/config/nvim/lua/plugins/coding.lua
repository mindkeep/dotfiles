return {
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				"bash-language-server",
				"clangd",
				"dockerfile-language-server",
				"gopls",
				"lua-language-server",
				"pyright",
				"yaml-language-server",
			})
		end,
	},
}
