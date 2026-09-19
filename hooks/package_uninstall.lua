local cmd = require("cmd")

function PLUGIN:PackageUninstall(ctx)
  for _, package in ipairs(ctx.packages) do
    cmd.exec('bun remove --global "$MISE_BUN_PACKAGE_NAME"', {
      env = { MISE_BUN_PACKAGE_NAME = package.name },
    })
  end
  return {}
end
