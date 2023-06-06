return {
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				"ansible-language-server",
				"bash-language-server",
				"clangd",
				"cpplint",
				"cpptools",
				"docker-compose-language-service",
				"dockerfile-language-server",
				"gopls",
				"jedi-language-server",
				"json-lsp",
				"jq",
				"lua-language-server",
				"prettier",
				"pyright",
				"yaml-language-server",
				"yq",
			})
		end,
	},
}
