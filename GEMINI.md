# Termux Bootstrap (tb) Project Context

**Tech Stack:** Bash Scripting, Fish Shell, Termux Environment
**Role:** Automated Bootstrap/Setup Manager for Android Termux.

## 🟢 Current Status
*   **Version:** v3.0.4
*   **Phase:** Workspace
*   **Focus:** Stability.

## 📚 Architecture
1.  **`setup.sh`:** The core installer. Handles logic, package installation, config injection, and updates.
2.  **`tb.sh`:** The CLI manager. Orchestrates Sessions (`tb session`), Web Terminals (`tb web`), and System Updates.
3.  **`uninstall.sh`:** The safety net. Reverts changes, cleaning configs and restoring backups.
4.  **`README.md`:** The single source of truth for users. Must mirror every feature in scripts.
5.  **`CHANGELOG.md`:** Version history and feature log.

## 🛡️ Gated Protocols

<PROTOCOL:PERCEIVE>
*   **Objective:** Maintain Mobile-First Ergonomics.
*   **Action:**
    1.  **Constraint:** Always assume the user is on a touch screen. Typing is expensive.
    2.  **Constraint:** Screen width is narrow (Portrait Mode). Avoid wide tables or long prompts.
    3.  **Dependency Awareness:** When adding a tool, check if it bloats the install size unnecessarily.
</PROTOCOL:PERCEIVE>

<PROTOCOL:ACT>
*   **Objective:** Safe & Modular Implementation.
*   **Action:**
    1.  **Idempotency:** All script actions must be repeatable without side effects (use `command -v` checks, block replacement in configs).
    2.  **Backups:** NEVER overwrite a user config file (`config.fish`, `starship.toml`) without creating a timestamped backup first.
    3.  **Syntax Safety:** Always escape double quotes inside variable strings in Bash to prevent "unexpected token" errors.
    4.  **Interface Consistency:** If a feature is added to `setup.sh`, it MUST be added to:
        *   The interactive menu (if applicable).
        *   The final success message.
        *   The `README.md` (Features list & Shortcuts table).
        *   The `uninstall.sh` script (for cleanup).
    5.  **Silent Upgrades:** When running `pkg upgrade`, always use `-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"` to prevent confusing prompts about config files during bootstrapping.
</PROTOCOL:ACT>

<PROTOCOL:VERIFY>
*   **Objective:** Prevent Configuration Drift.
*   **Action:**
    1.  **The "Trinity Check":** Before finishing any task, verify consistency across `setup.sh` (Installer), `uninstall.sh` (Cleaner), and `README.md` (Docs).
    2.  **Syntax Check:** Run `bash -n setup.sh` and `bash -n uninstall.sh` to catch syntax errors before committing.
</PROTOCOL:VERIFY>

<PROTOCOL:WORKFLOW>
*   **Objective:** Git & Documentation Best Practices.
*   **Action:**
    1.  Use Conventional Commits (e.g., `Feat:`, `Fix:`, `Docs:`).
    2.  Commit frequently when a logical unit of work is done.
    3.  Push immediately after committing.
    4.  **Documentation Sync:** NEVER leave `GEMINI.md` or `README.md` in a stale state. Update them immediately with every implementation change to ensure they reflect the current codebase.
</PROTOCOL:WORKFLOW>
