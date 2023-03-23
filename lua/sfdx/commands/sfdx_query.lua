-- SFDX query command
local config = require("sfdx.config")
local utils = require("sfdx.utils")

return function()
	local query = vim.fn.input("Enter query: ")
	local command = config.options.sfdx_exe .. ' data query -q "' .. query .. '"'

	utils.openBuffer("SFDX QUERY RESULTS")

	if config.options.clear_output then
		utils.clearBuffer()
	end

	utils.addLineToBuffer("-- QUERY:")
	utils.addLineToBuffer("-- " .. query)

	local gotErrors = false

	local jobOpts = {
		on_stdout = utils.logOutput,
		on_stderr = function(_, data, _)
			for _, err in next, data do
				if string.match(err, "Error") then
					utils.notify("Error running query", true)
					utils.logOutput(_, data)
					gotErrors = true
					break
				end
			end
		end,
		on_exit = function(_, _, _)
			if not gotErrors then
				utils.notify("SFDX Query finished.", false)
			end
		end,
		stdout_buffered = true,
	}
	vim.fn.jobstart(command, jobOpts)
end
