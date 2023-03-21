local config = require("sfdx.config")
local commands = require("sfdx.commands")

local SFDX = {}

-- SFDX.sfdx_deploy = commands.sfdx_deploy

SFDX.setup = function(options)
  -- setup config and defaults
  config.setup(options)

  -- create commands
  --
  -- SfdxDeploy - deploy source and show deployment errors, overwrite source on success.
  vim.api.nvim_create_user_command("SfdxDeploy", function()
    commands.sfdx_deploy(false)
  end, {})
  -- SfdxValidate - validate source, will not overwrite on success.
  vim.api.nvim_create_user_command("SfdxValidate", function()
    commands.sfdx_deploy(true)
  end, {})
end

return SFDX
