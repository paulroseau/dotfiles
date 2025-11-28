# Type safety
- DON'T: Ship dynamically typed code that’s prone to hard-to-catch bugs.
- DO: Use LuaCATS annotations and lua-language-server to catch issues early (e.g., in CI).

# User Commands
- DON'T: Create a separate user command for every action and clutter completion.
- DO: Use a single scoped command with subcommands and proper per-subcommand completion.

# Keymaps
- DON'T: Auto-create lots of keymaps that may conflict with users.
- DON'T: Invent a custom DSL for keymaps via setup; use the built-in API instead.
- DO: Expose <Plug> mappings so users can bind keys safely and flexibly.
- DO: Expose a Lua API for keymaps if options are complex or Vimscript support isn’t needed.

# Initialization
- DON'T: Require calling a setup function just to use the plugin.
- DO: Separate config from initialization and auto-init smartly with minimal startup cost.

# Lazy loading
- DON'T: Depend on plugin managers to implement lazy loading for you.
- DO: Defer requires and initialize via lightweight plugin/ftplugin entrypoints tuned to usage.

# Configuration
- DO: Type your public config with LuaCATS and keep internal config non-nil via merging.
- DO: Validate merged config (types, unknown fields) and surface clear errors.

# Troubleshooting
- DO: Provide health checks (lua/{plugin}/health.lua) to report config, init, and deps status.

# Versioning and releases
- DON'T: Use 0ver or skip versioning to avoid committing to stability.
- DO: Use SemVer and deprecations (vim.deprecate or annotations) to communicate changes.
- DO: Automate tagging/releases and publish to luarocks.org.

# Documentation
- DO: Provide vimdoc so users can read :h {plugin}.
- DON'T: Dump raw generated references into doc without curated docs.

# Testing
- DO: Automate tests thoroughly.
- DON'T: Use plenary.nvim’s test framework.
- DO: Use busted (with luarocks) for powerful, standard Lua testing.

# Lua compatibility
- DON'T: Rely on LuaJIT-only extensions without declaring the requirement.
- DO: Target Lua 5.1 API for compatibility across all Neovim builds.

# Integrating with other plugins
- DO: Integrate with popular plugins (e.g., Telescope, lualine) or expose hooks for others.

