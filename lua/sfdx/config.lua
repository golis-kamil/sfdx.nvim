local M = {}

M.namespace = vim.api.nvim_create_namespace("SFDX")

local defaults = {
  -- some default config
  sfdx_exe = "sfdx",
}

M.options = {}

function M.setup(options)
  M.options = vim.tbl_deep_extend("force", {}, defaults, options or {})
end

return M
