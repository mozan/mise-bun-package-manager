# mise-bun-package-manager

A [mise](https://mise.jdx.dev/) bootstrap package-manager plugin for globally installed [Bun](https://bun.com/) packages.

It lets you declare Bun global packages in `[bootstrap.packages]`:

```toml
[tools]
bun = "1.4.2"

[bootstrap.plugins]
bun = "https://github.com/mozan/mise-bun-package-manager"

[bootstrap.packages]
"bun:cline" = "3.0.61"
```

Then run:

```sh
mise bootstrap
```

## Behavior

- `PackageInstalled` reads Bun's global `package.json` and is side-effect free.
- Missing packages are installed with `bun add --global --exact`.
- Changing a pinned version upgrades or downgrades the package.
- `latest` installs the current latest version when an install/upgrade action is requested.
- Explicit mise package upgrades re-add the selected package at its requested version (or `latest`).
- Explicit mise prune is supported with `bun remove --global` for packages mise owns.
- Scoped packages such as `@scope/tool` are supported because package identities are read directly from JSON.

Bun's default global state is `~/.bun/install/global/package.json`. If `BUN_INSTALL_GLOBAL_DIR` is set, this plugin reads that directory instead.

## Local development

From the parent directory of this repository:

```sh
mise plugins link --force package:bun "$PWD"
```

Or declare a local plugin directly in your mise config:

```toml
[bootstrap.plugins]
bun = "/absolute/path/to/mise-bun-package-manager"
```

Check it with:

```sh
mise bootstrap plugins status
mise bootstrap packages status
mise bootstrap --dry-run
```

Then apply:

```sh
mise bootstrap
```

## Global executable PATH

Bun normally links global executables into `~/.bun/bin` (configurable with `BUN_INSTALL_BIN`). This plugin manages packages, not your interactive shell PATH. Ensure Bun's global bin directory is available in PATH if you want commands such as `cline` to resolve directly.

For example on POSIX shells:

```sh
export PATH="$HOME/.bun/bin:$PATH"
```

## Upgrades

For a pinned package:

```toml
"bun:cline" = "3.0.62"
```

If the global manifest reports another version, `mise bootstrap` selects it for installation and the plugin runs Bun with the requested exact version.

For `latest`:

```toml
"bun:cline" = "latest"
```

Use mise's package upgrade command to request an upgrade. The plugin installs `cline@latest` for that selected package without touching unrelated Bun globals.

## Pruning

The plugin implements `PackageUninstall`, so mise can prune packages that mise itself owns:

```sh
mise bootstrap packages prune --manager bun --dry-run
mise bootstrap packages prune --manager bun
```

mise deliberately does not adopt packages that were already installed before it managed them.

## Notes

This is a machine-global package manager integration. Bun owns the installed package state; mise only declares, checks, and applies it.
