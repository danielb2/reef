# Changelog

All notable changes to this project will be documented in this file.

## [1.6.0] - 2026-05-24

### Added
- **Fisher Migration Support**: `reef update` now mirrors Fisher's behavior by utilizing the `fish_plugins` file.
- **`fish_plugins` Integration**: Automatically tracks added and removed corals in `~/.config/fish/fish_plugins`.
- **Automatic Sync**: `reef update` (without arguments) now installs missing corals, removes extras, and updates existing ones based on the `fish_plugins` file.
- **Event Emitting**: Added events for plugin lifecycle management (`reef_add`, `reef_rm`, `reef_update`, and plugin-specific `_install`, `_uninstall`, `_update` events).
- **Local Path Support**: Ability to add corals from local directories using absolute or relative paths.
- **Improved Theme Handling**: Enhanced theme selection and automatic backup of existing `fish_prompt.fish` and `fish_right_prompt.fish` files.

### Changed
- Refactored `reef` function for better modularity with internal helper functions (`__reef_list`, `__reef_add`, `__reef_rm`, `__reef_update`).
- Updated `reef version` to 1.6.0.
- Improved repository resolution, including support for `file://` protocols and better GitHub URL handling.
- Optimized `reef add` to support multiple repositories in a single command.
- Standardized command aliases (e.g., `ls` for `list`, `up` for `update`).

### Fixed
- Improved error handling for missing `git` or invalid repository paths.
- Fixed tag/branch parsing when adding corals with the `@` syntax.
- Ensured proper cleanup and reloading after adding or removing corals.
