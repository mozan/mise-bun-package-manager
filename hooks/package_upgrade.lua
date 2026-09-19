local cmd = require("cmd")

local function upgrade_one(package, dry_run)
  local spec = package.name
  if package.version and package.version ~= "" and package.version ~= "latest" then
    spec = spec .. "@" .. package.version
  else
    spec = spec .. "@latest"
  end

  if dry_run then
    print("bun add --global --exact " .. spec)
    return
  end

  -- Re-adding an existing global package at the requested version handles both
  -- upgrades and downgrades, and --exact keeps package.json useful as status state.
  cmd.exec('bun add --global --exact "$MISE_BUN_PACKAGE_SPEC"', {
    env = { MISE_BUN_PACKAGE_SPEC = spec },
  })
end

function PLUGIN:PackageUpgrade(ctx)
  for _, package in ipairs(ctx.packages) do
    upgrade_one(package, ctx.dry_run)
  end
  return {}
end
