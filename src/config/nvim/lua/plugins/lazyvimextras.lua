-- only load copilot if .load_copilot is present
if vim.loop.fs_stat(vim.fn.stdpath("config") .. "/.load_extras") == nil then
	return {}
else
	return {
		{ import = "lazyvim.plugins.extras.lang.json" },
		{ import = "lazyvim.plugins.extras.lang.go" },
		{ import = "lazyvim.plugins.extras.lang.python" },
		{ import = "lazyvim.plugins.extras.lang.rust" },
	}
end
