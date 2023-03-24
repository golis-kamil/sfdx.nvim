local M = {}

M.namespace = vim.api.nvim_create_namespace("SFDX")

local defaults = {
	-- SFDX CLI executable, default is sfdx
	sfdx_exe = "sfdx",
	-- Clear Output buffer after each CLI execution
	clear_output = false,
}

M.options = {}

function M.setup(options)
	M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

return M
