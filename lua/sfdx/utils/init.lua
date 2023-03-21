local M = {}

local root = vim.fn.getcwd() -- get the current working directory

local function file_exists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

function M.hasFile(filename)
	local filepath = root .. "/" .. filename -- construct the full file path
	return file_exists(filepath)
end

function M.getCurrentBufferNumber()
	return vim.api.nvim_get_current_buf()
end

function M.getCurrentBufferName()
	return vim.api.nvim_buf_get_name(0)
end

return M
