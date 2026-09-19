local cmd = require("cmd")

local function install_one(package, dry_run)
  local spec = package.name
  if package.version and package.version ~= "" and package.version ~= "latest" then
    spec = spec .. "@" .. package.version
  elseif package.version == "latest" then
    spec = spec .. "@latest"
  end

  if dry_run then
    print("bun add --global --exact " .. spec)
    return
  end

  cmd.exec('bun add --global --exact "$MISE_BUN_PACKAGE_SPEC"', {
    env = { MISE_BUN_PACKAGE_SPEC = spec },
  })
end

function PLUGIN:PackageInstall(ctx)
  for _, package in ipairs(ctx.packages) do
    install_one(package, ctx.dry_run)
  end
  return {}
end
