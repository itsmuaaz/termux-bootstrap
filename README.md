# Termux Bootstrap (`tb`) v2.9.11

A modular, safe, and mobile-optimized bootstrap script and CLI manager for your Termux environment. Turn a fresh Termux install into a powerful development environment in minutes.

Now powered by the **`tb`** command-line manager.

[📜 View Changelog](CHANGELOG.md)

| Setup Menu | TB Manager Guide |
| :---: | :---: |
| ![Setup](setup.png) | ![TB Menu](tb-menu.png) |

## Features

### 🚀 Core Utilities
- **Git**: Distributed version control.
- **Node.js**: JavaScript runtime (LTS).
- **Python**: Popular programming language.

### 🐠 Fish Shell (Optional)
- **Interactive Shell**: Friendly shell with auto-completions and syntax highlighting.
- **Aliases**: Pre-configured shortcuts for mobile efficiency (only available if Fish is installed).

### 📦 Community Extras (New!)
- **Media Suite**: Installs `yt-dlp` (YouTube) and `spotDL` (Spotify) with **FFmpeg**.
    - *Optimized:* Automatically configures downloads to save to `/sdcard/Download/Termux` and `/sdcard/Music`.
    - *Note:* `spotDL` installation involves compiling heavy dependencies. It may take 5-15 minutes. A timeout protection is in place to prevent infinite hangs.
- **Termux Whisper**: Installs [termux-whisper](https://github.com/itsmuaaz/termux-whisper) for offline, privacy-focused AI speech transcription on your phone.

### 📱 Mobile Optimizations (Portrait Mode)
- **Starship (Portrait Config)**: Optional 2-line prompt optimized for narrow phone screens.
- **Micro Editor**: Touch-friendly text editor with mouse/touch support enabled by default.
- **Narrow Aliases**: Shortcuts like `gl` (git log graph) designed to fit on phone screens.
- **Clipboard Sync**: `copy` and `paste` commands to sync with Android clipboard.

### 🎨 Modern UI ("The Ricing")
- **Lsd**: The next gen `ls` command with colors and icons.
- **Bat**: A `cat` clone with syntax highlighting and Git integration.
- **Zoxide**: A smarter `cd` command that remembers your frequent directories.
- **Fzf**: Command-line fuzzy finder.
- **Glow**: Render Markdown on the CLI (used for Gemini outputs).
- **Nerd Fonts**: Automatically installs **JetBrains Mono Nerd Font (No Ligatures)**.
    - *Why No Ligatures?* Prevents rendering freezes/input lag on some Android devices while still providing icons.

### 🛡️ Safety & Config
- **Idempotent**: Can be run multiple times without duplicating configurations.
- **Backups**: Automatically backs up files (`config.fish`, fonts) before modifying them.
- **Interactive Menu**: Select your components at the start ("Set & Forget").
- **Smart Notifications**: Vibrates and sends a Toast notification when setup is complete.
- **Uninstaller**: Includes `uninstall.sh` to revert changes and restore backups.

## Installation

![Install QR Code](https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=curl%20-sL%20https%3A%2F%2Fraw.githubusercontent.com%2Fitsmuaaz%2Ftermux-bootstrap%2Fmain%2Fsetup.sh%20%7C%20bash)

### Option 1: One-Liner (Recommended)

Requires `curl`.

```bash
pkg install curl -y
curl -sL https://raw.githubusercontent.com/itsmuaaz/termux-bootstrap/main/setup.sh | bash
```

### Option 2: Clone and Run

```bash
pkg install git -y
git clone https://github.com/itsmuaaz/termux-bootstrap.git
cd termux-bootstrap
chmod +x setup.sh
./setup.sh
```

### Silent Mode (No Prompts)

Ideal for automated setups.

```bash
./setup.sh -y
```

## Uninstalling

To revert changes, run the `uninstall.sh` script included in the repository:

```bash
cd termux-bootstrap
./uninstall.sh
```
This script will:
*   Remove injected configurations from `config.fish`.
*   Restore backed-up configuration files and fonts (if found).
*   Offer to uninstall installed packages and tools.
*   Revert your default shell to Bash.

## Shortcuts & Aliases

To make mobile usage easier, the following shortcuts are included. Type **`tb`** in your terminal to see this list anytime.

| Alias | Command | Description |
| :--- | :--- | :--- |
| **`tb`** | *(Wrapper)* | **Display help & manage environment** |
| **`tb update`** | `...` | Full System Update (System + Scripts) |
| **`tb sync`** | `...` | Sync Bootstrap scripts with GitHub only |
| **`tb web`** | `...` | Web Terminal (Use --session for tmux) |
| **`video`** | `yt-dlp ...` | Download video to `/sdcard/Download/Termux` |
| **`music`** | `spotdl ...` | Smart download (Lyrics, LRC, Metadata) |
| **`whisper`** | `termux-whisper` | Launch the AI Transcriber |
| `upgrade-all` | *(Deprecated)* | Alias for `tb update` |
| `open` | `termux-open` | Open file in Android app |
| `serve` | `python...` | Start web server in current dir |
| `copy` | `termux-clipboard-set` | Pipe text to Android clipboard |
| `paste` | `termux-clipboard-get` | Paste from Android clipboard |
| `gl` | `git log --oneline...` | **Narrow** git log for phones |
| `up` | `pkg update && upgrade` | Update system packages |
| `in` | `pkg install` | Install package(s) |
| `c` | `clear` | Clear screen |
| `..` | `cd ..` | Go up one directory |

> **Note:** For `copy`/`paste` to work, you must have the [Termux:API](https://f-droid.org/en/packages/com.termux.api/) app installed on your Android device.

## Post-Install Guide

1.  **Restart Termux** to load the new settings.
2.  **Configure Gemini**:
    - Get a free API Key from [Google AI Studio](https://aistudio.google.com/app/apikey).
    - Run `gemini configure` and paste your key.
    - Test it: `ask "Hello"`
3.  **Try the Extras**:
    *   `video "https://youtube.com/watch?v=..."`
    *   `music "https://open.spotify.com/track/..."`

## Credits

- Inspired by [termux-fish](https://github.com/msn-05/termux-fish).
- Uses [Starship](https://starship.rs) and [Nerd Fonts](https://www.nerdfonts.com).
- Optimized Gemini CLI provided by [@mmmbuto/gemini-cli-termux](https://www.npmjs.com/package/@mmmbuto/gemini-cli-termux).
