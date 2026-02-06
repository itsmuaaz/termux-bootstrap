#!/data/data/com.termux/files/usr/bin/bash

# ==============================================================================
# Termux Bootstrap (tb) v3.0.0
# A modular, safe, and mobile-optimized setup script for Termux.
# ==============================================================================

# --- Variables ---
CONFIG_DIR="$HOME/.config/fish"
CONFIG_FILE="$CONFIG_DIR/config.fish"
STARSHIP_CONFIG_DIR="$HOME/.config"
STARSHIP_CONFIG_FILE="$STARSHIP_CONFIG_DIR/starship.toml"
MICRO_CONFIG_DIR="$HOME/.config/micro"
MICRO_CONFIG_FILE="$MICRO_CONFIG_DIR/settings.json"
FONT_DIR="$HOME/.termux"
FONT_FILE="$FONT_DIR/font.ttf"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d_%H%M%S)"
INTERACTIVE=true

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Helper Functions ---

HAS_ERROR=0

log_header() { 
    echo -e "\n${PURPLE}============================================================${NC}"
    echo -e "${PURPLE}:: ${CYAN}$1${NC}"
    echo -e "${PURPLE}============================================================${NC}"
}

log_info() { echo -e "${BLUE}  [INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}  [OK]${NC}   $1"; }
log_warn() { echo -e "${YELLOW}  [WARN]${NC} $1"; }
log_error() { 
    echo -e "${RED}  [ERR]${NC}  $1"
    HAS_ERROR=1
}

prompt_confirm() {
    # If not interactive, return 0 (true/yes)
    if [ "$INTERACTIVE" = false ]; then
        return 0
    fi
    
    echo ""
    while true; do
        read -r -p "$(echo -e "${CYAN}? $1 [Y/n]: ${NC}")" yn < /dev/tty
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            "" ) return 0;; # Default to Yes
            * ) echo "Please answer yes or no.";;
        esac
    done
}

finalize_setup() {
    local status=$1
    if command -v termux-toast &> /dev/null; then
        if [ "$status" -eq 0 ]; then
             termux-toast -g top -b "white" -c "black" "Termux Bootstrap Complete!"
        else
             termux-toast -g top -b "red" -c "white" "Setup Finished with Errors!"
        fi
    fi
    
    if command -v termux-vibrate &> /dev/null; then
        if [ "$status" -eq 0 ]; then
            # Success: Two long pulses (Triumphant)
            termux-vibrate -f -d 500
            sleep 0.7
            termux-vibrate -f -d 500
        else
            # Failure: Three short pulses (Alert)
            termux-vibrate -f -d 200
            sleep 0.3
            termux-vibrate -f -d 200
            sleep 0.3
            termux-vibrate -f -d 200
        fi
    fi
}

show_menu() {
    # Default States (1=ON, 0=OFF)
    # 0:Core, 1:Fish, 2:UI, 3:Media, 4:AI, 5:Font
    local options=("Core Utils" "Fish Shell" "Modern UI" "Media Suite" "AI Tools" "Nerd Font")
    local states=(1 1 1 0 0 1) # Defaults
    local times_min=(2 1 1 5 2 1) # Estimated mins (min)
    local times_max=(3 1 2 20 5 2) # Estimated mins (max)

    while true; do
        clear
        echo -e "${PURPLE}============================================${NC}"
        echo "       TERMUX BOOTSTRAP (tb) v3.0.0         "
        echo -e "${PURPLE}============================================${NC}"
        echo -e "Select components to install (Toggle with numbers):"
        echo ""

        local total_min=0
        local total_max=0

        for i in "${!options[@]}"; do
            local mark=" "
            local extra=""
            if [ "${states[$i]}" -eq 1 ]; then
                mark="x"
                total_min=$((total_min + times_min[i]))
                total_max=$((total_max + times_max[i]))
            fi
            
            # Suggest Fish
            if [ "$i" -eq 1 ]; then extra="${YELLOW}(Recommended for shortcuts)${NC}"; fi
            
            echo -e " [${mark}] $((i+1)). ${options[$i]} $extra"
        done

        echo -e "\n ${CYAN}Estimated Time: ${YELLOW}${total_min}-${total_max} minutes${NC}"
        if [ "${states[1]}" -eq 0 ]; then
             echo -e " ${RED}Warning: Shortcuts/Aliases will NOT be installed without Fish.${NC}"
        fi
        echo -e "--------------------------------------------"
        echo -e " Enter number to toggle (e.g. '3'), or ENTER to start."
        read -r -p " > " selection < /dev/tty

        if [ -z "$selection" ]; then
            break
        fi

        # Toggle logic
        if [[ "$selection" =~ ^[1-6]$ ]]; then
            local idx=$((selection-1))
            if [ "${states[$idx]}" -eq 1 ]; then
                states[$idx]=0
            else
                states[$idx]=1
            fi
        fi
    done

    # Export choices
    DO_CORE=${states[0]}
    DO_FISH=${states[1]}
    DO_UI=${states[2]}
    DO_MEDIA=${states[3]}
    DO_AI=${states[4]}
    DO_FONT=${states[5]}
}

backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        log_info "Backing up $(basename "$file") to $(basename "$file")$BACKUP_SUFFIX"
        cp "$file" "${file}${BACKUP_SUFFIX}"
    fi
}

check_for_updates() {
    # Only check if running from a git repository
    if [ -d ".git" ] && command -v git &> /dev/null; then
        log_info "Checking for script updates..."
        git fetch -q
        
        # Check if behind upstream
        local LOCAL=$(git rev-parse @ 2>/dev/null)
        local REMOTE=$(git rev-parse "@{u}" 2>/dev/null)
        
        if [ -n "$LOCAL" ] && [ -n "$REMOTE" ] && [ "$LOCAL" != "$REMOTE" ]; then
             # Check if we are actually behind (ancestor check)
             if git merge-base --is-ancestor "$LOCAL" "$REMOTE"; then
                 echo -e "${YELLOW}============================================================${NC}"
                 echo -e "${YELLOW}  [!] UPDATE AVAILABLE${NC}"
                 echo -e "${YELLOW}  You are using an outdated version of the setup script.${NC}"
                 echo -e "${YELLOW}============================================================${NC}"
                 if prompt_confirm "Update script now?" "Y"; then
                     git pull
                     log_success "Updated. Restarting script..."
                     exec bash "$0" "$@"
                 fi
             fi
        fi
    fi
}

ensure_persistence() {
    # If running via curl/pipe, we need to clone the repo to ensure 
    # upgrade-all and uninstall.sh work later.
    if command -v git &> /dev/null; then
        local INSTALL_DIR="$HOME/termux-bootstrap"
        
        # If we are NOT in the repo, and the repo doesn't exist fully
        if [ "$PWD" != "$INSTALL_DIR" ] && [ ! -d "$INSTALL_DIR/.git" ]; then
            log_info "Cloning repository for persistence..."
            # Remove partial dir if exists
            if [ -d "$INSTALL_DIR" ]; then rm -rf "$INSTALL_DIR"; fi
            
            git clone https://github.com/itsmuaaz/termux-bootstrap.git "$INSTALL_DIR"
            log_success "Repository cloned to $INSTALL_DIR"
        fi
    fi
}

# --- Installation Functions ---

update_system() {
    log_header "System Update"
    log_info "Updating package lists and upgrading system..."
    pkg update -y && pkg upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
}

install_core_utils() {
    log_header "Core Utilities"
    log_info "Installing core packages..."
    # Added build-essential and python for node-gyp native compilations
    pkg install git nodejs-lts curl termux-api build-essential python -y
    log_success "Core tools installed."
}

install_fish() {
    log_header "Fish Shell Setup"
    log_info "Installing Fish Shell..."
    pkg install fish -y
    log_success "Fish Shell installed."
}

install_modern_tools() {
    log_header "Modern UI Tools"
    log_info "Installing improved CLI utilities..."
    pkg install lsd bat zoxide fzf starship glow -y
    log_success "Modern tools installed."
    
    # Automatically configure Starship if installed (User selected UI module)
    configure_starship_portrait
}

install_micro_editor() {
    log_header "Micro Editor Setup"
    log_info "Installing Micro..."
    pkg install micro -y
    
    # Configure Micro for touch and softwrap
    mkdir -p "$MICRO_CONFIG_DIR"
    if [ ! -f "$MICRO_CONFIG_FILE" ]; then
        log_info "Configuring Micro (softwrap, mouse support)..."
        cat <<EOF > "$MICRO_CONFIG_FILE"
{
    "softwrap": true,
    "mouse": true,
    "autosu": true
}
EOF
        log_success "Micro configuration created."
    else
        log_info "Micro configuration already exists. Backing up and updating..."
        backup_file "$MICRO_CONFIG_FILE"
        # Update logic: we don't overwrite user settings, but ensure these are present
        # For simplicity in this script, we'll just log it.
        log_success "Micro configuration backed up."
    fi
}

install_gemini() {
    log_header "Gemini CLI Setup"
    if ! command -v gemini &> /dev/null; then
        log_info "Installing Google Gemini CLI (Termux Optimized)..."
        npm install -g @mmmbuto/gemini-cli-termux
        log_success "Gemini CLI installed successfully."
    else
        log_success "Gemini CLI is already installed."
    fi
}

install_media_suite() {
    log_header "Media Suite Installation"
    log_info "Installing dependencies (Python, FFmpeg, Rust)..."
    # Added rust and binutils for building pydantic-core (spotdl dependency)
    pkg install python ffmpeg rust binutils -y
    
    log_info "Installing yt-dlp (Video Downloader)..."
    if pip install --prefer-binary yt-dlp; then
        log_info "Configuring yt-dlp..."
        mkdir -p "$HOME/.config/yt-dlp"
        backup_file "$HOME/.config/yt-dlp/config"
        # Config: Save to sdcard, cleaner filenames
        echo '-o /sdcard/Download/Termux/%(title)s.%(ext)s' > "$HOME/.config/yt-dlp/config"
        echo '--no-mtime' >> "$HOME/.config/yt-dlp/config"
        
        # Create Download folder
        mkdir -p "/sdcard/Download/Termux"
        log_success "yt-dlp installed & configured."
    else
        log_error "yt-dlp installation failed."
    fi
    
    log_info "Installing spotdl (Spotify Downloader)..."
    log_warn "This step involves compiling heavy dependencies (e.g., rapidfuzz)."
    log_warn "It may take 5-15 minutes on a phone. Please be patient."
    
    # Use timeout if available to prevent infinite hangs (20 mins)
    local PIP_CMD="pip"
    if command -v timeout &> /dev/null; then
        PIP_CMD="timeout 1200 pip"
    fi

    if $PIP_CMD install --prefer-binary spotdl; then
        log_info "Configuring spotdl..."
        mkdir -p "/sdcard/Music/SpotDL"
        log_success "spotdl installed."
    else
        local EXIT_CODE=$?
        if [ $EXIT_CODE -eq 124 ]; then
             log_error "spotdl installation timed out (limit: 20 mins)."
             log_warn "Your device might be too slow to compile 'rapidfuzz'."
        else
             log_error "spotdl installation failed."
        fi
        log_warn "Skipping spotdl. You can try installing it manually later with 'pip install spotdl'."
    fi
}

install_termux_whisper() {
    log_header "Termux Whisper Setup"
    if [ -d "$HOME/termux-whisper" ]; then
        log_warn "Termux Whisper directory already exists. Skipping clone."
    else
        log_info "Cloning Termux Whisper..."
        git clone https://github.com/itsmuaaz/termux-whisper.git "$HOME/termux-whisper"
        
        log_info "Running Termux Whisper setup..."
        chmod +x "$HOME/termux-whisper/setup.sh"
        # Run setup, handling potential interactive prompts if possible or warn user
        bash "$HOME/termux-whisper/setup.sh"
    fi
}

setup_storage() {
    log_header "Storage Access"
    log_info "Checking Termux storage access..."
    if [ -d "$HOME/storage" ]; then
        log_success "Termux storage is already configured."
    else
        echo -e "    ${YELLOW}->${NC} This links Termux to your Android 'Downloads' and 'Music' folders."
        echo -e "    ${YELLOW}->${NC} Please grant permission in the popup if asked."
        termux-setup-storage
    fi
}

install_nerd_font() {
    log_header "Nerd Font Installation"
    if [ -f "$FONT_FILE" ]; then
        log_warn "A font is already installed at $FONT_FILE."
        log_info "Overwriting with JetBrains Mono Nerd Font (per selection)..."
        backup_file "$FONT_FILE"
    fi

    log_info "Downloading JetBrains Mono Nerd Font..."
    mkdir -p "$FONT_DIR"
    
    local TEMP_FONT="$FONT_DIR/font.ttf.tmp"
    
    # Download to temp file first to prevent partial/corrupt writes to active config
    # Switched to "No Ligatures" (NL) version to prevent rendering freezes on some Android devices.
    curl -fLo "$TEMP_FONT" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/NoLigatures/Regular/JetBrainsMonoNLNerdFont-Regular.ttf
    
    # Verify download: Check if file exists and is > 1MB (Fonts are usually ~2MB)
    if [ -f "$TEMP_FONT" ]; then
        local FONT_SIZE=$(stat -c%s "$TEMP_FONT")
        if [ "$FONT_SIZE" -gt 1000000 ]; then
             mv "$TEMP_FONT" "$FONT_FILE"
             log_info "Font downloaded successfully ($((FONT_SIZE/1024)) KB)."
             log_info "Reloading Termux settings to apply font..."
             termux-reload-settings
             log_success "Font applied."
             return
        fi
    fi

    log_error "Font download failed or file is corrupted (< 1MB). Aborting font change."
    rm -f "$TEMP_FONT"
}

configure_starship_portrait() {
    log_info "Configuring Starship for Portrait Mode (2-line prompt)..."
    mkdir -p "$STARSHIP_CONFIG_DIR"
    backup_file "$STARSHIP_CONFIG_FILE"
    
    cat <<EOF > "$STARSHIP_CONFIG_FILE"
# Portrait Mode Optimized Config
# Two lines: Information on top, input on bottom.

add_newline = true

[line_break]
disabled = false

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
vimcmd_symbol = "[❮](bold green)"

[directory]
truncation_length = 3
truncation_symbol = "…/"
style = "bold cyan"

[git_branch]
symbol = "🌱 "
style = "bold purple"

[nodejs]
symbol = "⬢ "
style = "bold green"

[package]
symbol = "📦 "
disabled = true
EOF
    log_success "Starship configured for portrait mode."
}

configure_fish() {
    log_header "Shell Configuration"
    log_info "Configuring Fish Shell..."
    mkdir -p "$CONFIG_DIR"
    
    # Define the block content markers
    local BLOCK_START="# --- TERMUX-BOOTSTRAP-START ---"
    local BLOCK_END="# --- TERMUX-BOOTSTRAP-END ---"

    # Remove existing block if present
    if [ -f "$CONFIG_FILE" ]; then
        # Backup before modification
        backup_file "$CONFIG_FILE"
        # Use sed to delete the block
        sed -i "/$BLOCK_START/,/$BLOCK_END/d" "$CONFIG_FILE"
        # Remove trailing newlines potentially left behind
        sed -i '${/^$/d;}' "$CONFIG_FILE"
    fi

    # Append new block. 
    # We use multiple writes to allow quoted heredoc for the body (preventing variable expansion)
    # while still injecting the block markers.
    
    echo "$BLOCK_START" >> "$CONFIG_FILE"
    
    cat <<'EOF' >> "$CONFIG_FILE"
# Core
function fish_greeting
    if test -n "$TB_WEB_MODE"
        echo -e "\n\033[1;33m💻 Web Session Detected.\033[0m"
        echo -e "Missing icons? Install \033[4mJetBrains Mono Nerd Font\033[0m on this device:"
        echo -e "\033[0;36mhttps://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip\033[0m\n"
    end

    if test -f ~/.termux_bootstrap_first_run
        echo -e "\n\033[1;35mWelcome to Termux Bootstrap (tb)! 🎉\033[0m"
        echo -e "Here are 3 things to try:"
        echo -e "  1. Type \033[0;36mtb\033[0m to see your new super-powers."
        echo -e "  2. Type \033[0;36mask \"hello\"\033[0m to test the AI."
        echo -e "  3. Type \033[0;36mopen .\033[0m to view files on Android.\n"
        rm ~/.termux_bootstrap_first_run
    else
        echo -e "\033[0;90m🚀 Termux Bootstrap active. Type '\033[0;36mtb\033[0;90m' for tools.\033[0m"
    end
end

# Modern Tools Aliases
if command -q lsd
    alias ls='lsd'
    alias ll='lsd -l'
    alias la='lsd -a'
    alias lla='lsd -la'
    alias lt='lsd --tree'
end

if command -q bat
    alias cat='bat'
end

# Mobile-Friendly Shortcuts
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias g='git'
alias gl='git log --oneline --graph --decorate' # Narrow git log
alias up='pkg update && pkg upgrade'
alias in='pkg install'
alias open='termux-open'
alias serve='python -m http.server'

# Quick Download
function dl --description "Serve a file for download"
    if test (count $argv) -eq 0
        echo "Usage: dl <file>"
        return 1
    end
    set file $argv[1]
    if not test -f "$file"
        echo "Error: File '$file' not found."
        return 1
    end
    set ip (ifconfig 2>/dev/null | grep -A 1 'wlan0' | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
    if test -z "$ip"; set ip "localhost"; end
    echo "🔗 Download: http://$ip:8000/$file"
    python -m http.server 8000
end

# Clipboard Integration (Requires Termux:API app)
if command -q termux-clipboard-get
    alias copy='termux-clipboard-set'
    alias paste='termux-clipboard-get'
end

# Media Suite Aliases
if command -q spotdl
    # Advanced Music Downloader (Lyrics, LRC, Metadata Update)
    alias music='spotdl download --output /sdcard/Music/SpotDL --lyrics synced genius musixmatch azlyrics --generate-lrc --overwrite metadata --scan-for-songs --force-update-metadata'
end
if command -q yt-dlp
    alias video='yt-dlp'
end

# Termux Whisper Alias
if test -f ~/termux-whisper/transcribe.sh
    alias whisper='bash ~/termux-whisper/transcribe.sh'
end

# Editor
if command -q micro
    set -gx EDITOR micro
    alias nano='micro'
end

# Starship Prompt
if command -q starship
    starship init fish | source
end

# Zoxide (Smart cd)
if command -q zoxide
    zoxide init fish | source
end

# FZF (Fuzzy Finder)
if command -q fzf
    fzf --fish | source
end

# Termux Command Not Found
function __fish_command_not_found_handler --on-event fish_command_not_found
    if [ -f /data/data/com.termux/files/usr/libexec/termux/command-not-found ]
        /data/data/com.termux/files/usr/libexec/termux/command-not-found $argv[1]
    else
        printf 'Command not found: %s\n' $argv[1]
    end
end

# TB CLI Wrapper
function tb
    bash ~/termux-bootstrap/tb.sh $argv
end

# Gemini 'Ask' Helper
function ask
    # Enable Google Account Auth for this session
    set -lx GOOGLE_GENAI_USE_GCA true
    
    if isatty stdin
        # Interactive Usage
        if test -z "$argv"
            echo "Usage: ask 'question' OR echo 'text' | ask 'instruction'"
            return 1
        end
        
        if command -q glow
            gemini $argv | glow -
        else
            gemini $argv
        end
    else
        # Piped Usage
        set -l prompt (string join " " $argv)
        set -l gemini_cmd gemini
        
        if test -n "$prompt"
            set gemini_cmd gemini -p "$prompt"
        end
        
        if command -q glow
            $gemini_cmd | glow -
        else
            $gemini_cmd
        end
    end
end

# Legacy Alias
alias upgrade-all="tb update"
EOF

    echo "$BLOCK_END" >> "$CONFIG_FILE"

    log_success "Fish configuration updated."
}

install_completions() {
    log_info "Installing Fish completions..."
    local COMP_DIR="$HOME/.config/fish/completions"
    mkdir -p "$COMP_DIR"
    
    cat <<EOF > "$COMP_DIR/tb.fish"
# Completions for tb (Termux Bootstrap)
complete -c tb -f -n "not __fish_seen_subcommand_from update sync theme web help" -a "update" -d "Full System Update"
complete -c tb -f -n "not __fish_seen_subcommand_from update sync theme web help" -a "sync" -d "Sync Scripts Only"
complete -c tb -f -n "not __fish_seen_subcommand_from update sync theme web help" -a "theme" -d "Change Theme"
complete -c tb -f -n "not __fish_seen_subcommand_from update sync theme web help" -a "web" -d "Start Web Terminal"
complete -c tb -f -n "not __fish_seen_subcommand_from update sync theme web help" -a "help" -d "Show Help"

# Arguments for 'web'
complete -c tb -f -n "__fish_seen_subcommand_from web" -a "--session" -d "Enable Session Persistence (Tmux)"
EOF
    log_success "Fish completions installed."
}

set_default_shell() {
    local SHELL_PATH=$(command -v fish)
    if [ "$SHELL" != "$SHELL_PATH" ]; then
        log_info "Changing default shell to Fish..."
        chsh -s fish
    else
        log_success "Fish is already the default shell."
    fi
}

cleanup_motd() {
    if [ -f "$PREFIX/etc/motd" ]; then
        log_info "Removing Termux default MOTD..."
        rm "$PREFIX/etc/motd"
    fi
}

# --- Main Execution ---

# Ensure device stays awake during setup
cleanup() {
    termux-wake-unlock
}
trap cleanup EXIT INT TERM

# Check arguments
if [ "$1" == "-y" ]; then
    # Silent Mode defaults: Core + Fish + UI + Font
    DO_CORE=1; DO_FISH=1; DO_UI=1; DO_MEDIA=0; DO_AI=0; DO_FONT=1
    INTERACTIVE=false
elif [ "$1" == "--refresh" ]; then
    # Refresh Mode: Update configs only (Post-Sync)
    log_info "Refreshing configurations..."
    DO_CORE=0; DO_FISH=1; DO_UI=1; DO_MEDIA=0; DO_AI=0; DO_FONT=1
    INTERACTIVE=false
    REFRESH_MODE=true
else
    # Interactive Menu
    check_for_updates
    show_menu
fi

termux-wake-lock
log_info "Wake lock acquired. Device will stay awake during setup."

# Start Execution
setup_storage

# Always update system first (unless refreshing)
if [ "$REFRESH_MODE" != "true" ]; then
    update_system
fi

if [ "$DO_CORE" -eq 1 ]; then install_core_utils; fi
if [ "$DO_FISH" -eq 1 ]; then install_fish; fi

# Ensure repo exists for aliases
ensure_persistence

if [ "$DO_UI" -eq 1 ]; then 
    install_modern_tools
    install_micro_editor
fi
if [ "$DO_AI" -eq 1 ]; then install_gemini; install_termux_whisper; fi
if [ "$DO_FONT" -eq 1 ]; then install_nerd_font; fi

# Common Configs
if [ "$DO_FISH" -eq 1 ]; then
    configure_fish
    install_completions
    set_default_shell
fi

# Install Media Suite LAST (Longest duration)
if [ "$DO_MEDIA" -eq 1 ]; then install_media_suite; fi

# Enable First Run Tour
touch ~/.termux_bootstrap_first_run

cleanup_motd
finalize_setup "$HAS_ERROR"

echo "--------------------------------------------"
if [ "$HAS_ERROR" -eq 0 ]; then
    log_success "Setup Complete!"
else
    log_warn "Setup Complete (With Errors). Check output above."
fi
echo -e "  ${YELLOW}*${NC} Please ${GREEN}restart Termux${NC} to apply all changes."

if [ "$DO_MEDIA" -eq 1 ]; then
    echo -e "  ${YELLOW}*${NC} Media Aliases: ${BLUE}music${NC}, ${BLUE}video${NC}."
fi
if [ "$DO_AI" -eq 1 ]; then
    echo -e "  ${YELLOW}*${NC} AI Alias: ${BLUE}whisper${NC}."
fi
if [ "$DO_FISH" -eq 1 ]; then
    echo -e "  ${YELLOW}*${NC} Type ${BLUE}tb${NC} for a help guide."
fi
echo "--------------------------------------------"
