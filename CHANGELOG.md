# Changelog

All notable changes to the **Termux Bootstrap (tb)** project will be documented in this file.

## [v2.9.10] - 2026-01-05
### Fixed
- **Web Terminal Copying:** Enabled `tmux` OSC 52 clipboard integration. Text copied via Tmux selection now syncs to the browser clipboard.
- **Mouse Control:** Added `Prefix + m` binding to toggle mouse mode. This allows temporarily disabling mouse capture to use native browser selection.
- **Stability:** Increased Tmux history limit to prevent buffer issues.

## [v2.9.9] - 2026-01-05
### Removed
- **Dashboard Mode:** Removed the `--dashboard` feature and its associated logic to simplify the codebase. `tb web --session` is now the standard for persistence.
- **Yazi/Sixel Integration:** Removed Sixel graphics passthrough and Yazi IPC integration due to compatibility issues.

## [v2.9.8] - 2026-01-05
### Fixed
- **Sixel Initialization:** Moved `tmux` configuration (passthrough enablement) to execute immediately after session creation. This fixes a race condition where `yazi` would launch before graphics support was active, resulting in broken image previews.

## [v2.9.7] - 2026-01-05
### Added
- **Yazi Integration:** Dashboard mode now automatically configures `yazi` with Tmux integration:
    - `<C-d>`: Syncs the adjacent shell pane to the selected directory.
    - `o`: Opens the selected file in `micro` in the adjacent pane.
- **Sixel Graphics:** Enabled `allow-passthrough` in Tmux sessions to support image previews (Sixel) in `yazi` via the web terminal.

## [v2.9.6] - 2026-01-05
### Fixed
- **Status Bar Persistence:** Web sessions now re-apply the cheat sheet status bar configuration on every attach, fixing missing UI elements in existing sessions.

## [v2.9.5] - 2026-01-05
### Changed
- **CLI Refinement:** Renamed `tb web --persist` to `tb web --session` for better semantic clarity.
- **Documentation:** Updated README with project screenshots.

## [v2.9.4] - 2026-01-05
### Added
- **Session Persistence:** `tb web --persist` now uses `tmux` to keep your web terminal alive after disconnect.
- **Status Bar:** Added a built-in shortcut cheat sheet to the bottom of persistent web sessions.

## [v2.9.3] - 2026-01-05
### Added
- **Context Awareness:** Web sessions now detect the browser environment and provide a direct download link for Nerd Fonts if icons are missing.

## [v2.9.2] - 2026-01-05
### Changed
- **Web Terminal:** Simplified `tb web` to run Fish directly, fixing input latency and focus issues on mobile browsers.

## [v2.9.0] - 2026-01-05
### Added
- **`tb web`:** New command to expose your Termux terminal over a local web URL for laptop access.

## [v2.8.1] - 2026-01-05
### Fixed
- **Sync Persistence:** `tb sync` now automatically re-runs setup logic (refresh mode) to ensure new configurations (aliases, completions) are applied immediately after an update.

## [v2.8.0] - 2026-01-05
### Added
- **Fish Completions:** Added Tab autocomplete support for the `tb` command (update, sync, theme, help).

## [v2.7.1] - 2026-01-05
### Changed
- **CLI Split:** Separated `tb update` (Full System Update) and `tb sync` (Script Sync Only) for better control.

## [v2.7.0] - 2026-01-05
### Added
- **`tb theme`:** Introduced an interactive theme switcher with popular color schemes (Dracula, Nord, Gruvbox, Matrix).

## [v2.6.0] - 2026-01-05
### Added
- **First Run Tour:** A welcoming guide that appears on the first shell launch to help new users get started.
- **QR Code:** Added to README for instant mobile installation (Scan-to-Copy).

## [v2.5.0] - 2026-01-05
### Changed
- **CLI Manager:** Introduced `tb.sh` as the core logic engine.
- **`tb` Command:** Promoted from a cheat sheet to a full environment manager (`tb help`, `tb update`).
- **Shell Agnostic:** Core update logic is now Bash-based, allowing usage outside of Fish.
- **Deployment:** Fixed `curl | bash` compatibility for Fish/Zsh users.

## [v2.4.4] - 2026-01-05
### Fixed
- **One-Liner Persistence:** The installer now silently clones the repo if run via pipe, ensuring `uninstall.sh` and `tb update` work later.
- **Automagic `ask`:** Fixed argument parsing bugs for piped input to the AI assistant.

## [v2.4.2] - 2026-01-05
### Added
- **Smart Greeting:** Replaced empty shell greeting with a subtle `tb` reminder.
- **Mobile Aliases:** Added `open` (termux-open) and `serve` (http.server).

## [v2.4.0] - 2026-01-05
### Changed
- **Modular Architecture:** Unbundled Fish Shell from Core Utilities. Users can now choose to install dev tools without switching shells.
- **Menu UX:** Added visual hints recommending Fish for the full experience.

## [v2.3.0] - 2026-01-05
### Added
- **"Set & Forget" Installer:** Replaced step-by-step prompts with a single interactive menu at the start.
- **Wake Lock:** Script now prevents device sleep during installation.
- **Smart Notifications:** Vibrates and sends a Toast message upon completion (Success/Failure).

## [v2.2.2] - 2026-01-05
### Fixed
- **Font Rendering:** Switched to "No Ligatures" Nerd Font to prevent terminal freezing on some Android devices.
- **Media Suite:** Moved to end of setup and increased timeout to 20m to handle compilation on slow devices.

## [v2.0.0] - Initial Release
- **Core:** Git, Node, Fish, Micro.
- **UI:** Starship, Lsd, Bat.
- **AI:** Gemini CLI integration.
