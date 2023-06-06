-- only load copilot if .load_copilot is present
if vim.loop.fs_stat(vim.fn.stdpath("config") .. "/.load_copilot") == nil then
	return {}
else
	return {
		import = "lazyvim.plugins.extras.coding.copilot",
		config = function(_, _)
			-- when the copilot plugin is loaded, default to disabled
			vim.cmd("Copilot disable")
		end,
		lazy = false,
	}
end
