local file = require("file")
local json = require("json")

local function global_dir()
  local configured = os.getenv("BUN_INSTALL_GLOBAL_DIR")
  if configured and configured ~= "" then
    return configured
  end

  local home = os.getenv("HOME") or os.getenv("USERPROFILE")
  if not home or home == "" then
    error("cannot determine Bun global directory: HOME/USERPROFILE is not set")
  end
  return file.join_path(home, ".bun", "install", "global")
end

local function read_dependencies()
  local manifest = file.join_path(global_dir(), "package.json")
  if not file.exists(manifest) then
    return {}
  end

  local ok_read, contents = pcall(file.read, manifest)
  if not ok_read then
    error("failed to read Bun global package.json: " .. tostring(contents))
  end

  local ok_json, data = pcall(json.decode, contents)
  if not ok_json then
    error("failed to parse Bun global package.json: " .. tostring(data))
  end

  if type(data) ~= "table" or type(data.dependencies) ~= "table" then
    return {}
  end
  return data.dependencies
end

function PLUGIN:PackageInstalled(ctx)
  local installed = read_dependencies()
  local results = {}

  for _, package in ipairs(ctx.packages) do
    local version = installed[package.name]
    table.insert(results, {
      name = package.name,
      state = version and "installed" or "missing",
      version = version,
    })
  end

  return { packages = results }
end
