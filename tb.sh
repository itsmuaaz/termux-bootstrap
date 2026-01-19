#!/data/data/com.termux/files/usr/bin/bash

# ==============================================================================
# Termux Bootstrap CLI (tb) v2.9.9
# The Swiss Army Knife for your Termux Environment.
# ==============================================================================

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# --- Commands ---

cmd_help() {
    echo -e "\n${PURPLE}============================================${NC}"
    echo -e "${PURPLE}       TERMUX BOOTSTRAP SHORTCUTS           ${NC}"
    echo -e "${PURPLE}============================================${NC}"
    
    echo -e "${GREEN}[Media]${NC}"
    echo -e "  ${CYAN}video${NC}   : Download video to /sdcard/Download"
    echo -e "  ${CYAN}music${NC}   : Smart Spotify download (+Lyrics/LRC)"
    
    echo -e "\n${GREEN}[AI]${NC}"
    echo -e "  ${CYAN}whisper${NC} : AI Speech-to-Text (Offline)"
    echo -e "  ${CYAN}ask${NC}     : Ask AI (Supports piping: echo '...' | ask 'Summary')"
    
    echo -e "\n${GREEN}[Git]${NC}"
    echo -e "  ${CYAN}g${NC}       : git shortcut"
    echo -e "  ${CYAN}gl${NC}      : Pretty, narrow git log for mobile"
    
    echo -e "\n${GREEN}[System]${NC}"
    echo -e "  ${CYAN}up${NC}      : pkg update && upgrade"
    echo -e "  ${CYAN}in${NC}      : pkg install"
    echo -e "  ${CYAN}open${NC}    : Open file in Android app"
    echo -e "  ${CYAN}serve${NC}   : Start web server in current dir"
    echo -e "  ${CYAN}copy${NC}    : Pipe to Android clipboard"
    echo -e "  ${CYAN}paste${NC}   : Paste from Android clipboard"
    echo -e "  ${CYAN}c${NC}       : Clear screen"
    
    echo -e "\n${GREEN}[CLI Manager]${NC}"
    echo -e "  ${CYAN}tb theme${NC}  : Change terminal color scheme"
    echo -e "  ${CYAN}tb update${NC} : Update System + Bootstrap"
    echo -e "  ${CYAN}tb help${NC}   : Show this guide"
    
    echo -e "\n${YELLOW}Tip: Type 'tb <command>' to manage your environment.${NC}\n"
}

cmd_theme() {
    local TERMUX_DIR="$HOME/.termux"
    local COLOR_FILE="$TERMUX_DIR/colors.properties"
    mkdir -p "$TERMUX_DIR"

    echo -e "${PURPLE}Select a Theme:${NC}"
    echo "1. 🧛 Dracula"
    echo "2. ❄️  Nord"
    echo "3. 🦄 Gruvbox"
    echo "4. 🕶️  Matrix"
    echo "5. 🔙 Reset (Default)"
    echo ""
    read -r -p "Choice [1-5]: " choice

    case "$choice" in
        1) # Dracula
            cat <<EOF > "$COLOR_FILE"
background=#282a36
foreground=#f8f8f2
cursor=#bbbbbb
color0=#000000
color1=#ff5555
color2=#50fa7b
color3=#f1fa8c
color4=#bd93f9
color5=#ff79c6
color6=#8be9fd
color7=#bfbfbf
color8=#4d4d4d
color9=#ff6e67
color10=#5af78e
color11=#f4f99d
color12=#caa9fa
color13=#ff92d0
color14=#9aedfe
color15=#e6e6e6
EOF
            echo -e "${GREEN}[OK] Applied Dracula.${NC}"
            ;;
        2) # Nord
            cat <<EOF > "$COLOR_FILE"
background=#2e3440
foreground=#d8dee9
cursor=#d8dee9
color0=#3b4252
color1=#bf616a
color2=#a3be8c
color3=#ebcb8b
color4=#81a1c1
color5=#b48ead
color6=#88c0d0
color7=#e5e9f0
color8=#4c566a
color9=#bf616a
color10=#a3be8c
color11=#ebcb8b
color12=#81a1c1
color13=#b48ead
color14=#8fbcbb
color15=#eceff4
EOF
            echo -e "${GREEN}[OK] Applied Nord.${NC}"
            ;;
        3) # Gruvbox Dark
            cat <<EOF > "$COLOR_FILE"
background=#282828
foreground=#ebdbb2
cursor=#ebdbb2
color0=#282828
color1=#cc241d
color2=#98971a
color3=#d79921
color4=#458588
color5=#b16286
color6=#689d6a
color7=#a89984
color8=#928374
color9=#fb4934
color10=#b8bb26
color11=#fabd2f
color12=#83a598
color13=#d3869b
color14=#8ec07c
color15=#ebdbb2
EOF
            echo -e "${GREEN}[OK] Applied Gruvbox.${NC}"
            ;;
        4) # Matrix
            cat <<EOF > "$COLOR_FILE"
background=#000000
foreground=#00ff00
cursor=#00ff00
color0=#000000
color1=#00ff00
color2=#00ff00
color3=#00ff00
color4=#003300
color5=#00ff00
color6=#00ff00
color7=#00ff00
color8=#003300
color9=#00ff00
color10=#00ff00
color11=#00ff00
color12=#00ff00
color13=#00ff00
color14=#00ff00
color15=#00ff00
EOF
            echo -e "${GREEN}[OK] Applied Matrix (Hack the planet!).${NC}"
            ;;
        5) # Reset
            if [ -f "$COLOR_FILE" ]; then rm "$COLOR_FILE"; fi
            echo -e "${GREEN}[OK] Reset to Termux default.${NC}"
            ;;
        *)
            echo -e "${RED}Invalid choice.${NC}"
            return
            ;;
    esac

    termux-reload-settings
}

cmd_sync() {
    if [ -d "$HOME/termux-bootstrap/.git" ]; then
        echo -e "${BLUE}[-] Syncing Termux Bootstrap with GitHub...${NC}"
        (
            cd "$HOME/termux-bootstrap" || return
            if git pull; then
                echo -e "${GREEN}[OK] Scripts synced.${NC}"
                
                # Apply new configurations (Refresh Mode)
                if [ -x "./setup.sh" ]; then
                    echo -e "${BLUE}[*] Applying configuration updates...${NC}"
                    ./setup.sh --refresh
                fi
            fi
        )
    else
        echo -e "${RED}[ERR] Bootstrap repo not found at $HOME/termux-bootstrap.${NC}"
    fi
}

cmd_update() {
    echo -e "${BLUE}[-] Updating System Packages (pkg)...${NC}"
    pkg update -y && pkg upgrade -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\"

    if command -v npm &> /dev/null; then
        echo -e "${BLUE}[-] Updating NPM Global Packages...${NC}"
        npm update -g
    fi

    if command -v pip &> /dev/null; then
        echo -e "${BLUE}[-] Updating Python Tools...${NC}"
        pip install --upgrade yt-dlp spotdl 2>/dev/null
    fi

    if [ -d "$HOME/termux-whisper/.git" ]; then
        echo -e "${BLUE}[-] Updating Termux Whisper...${NC}"
        (cd "$HOME/termux-whisper" && git pull)
    fi

    # Sync Bootstrap scripts as well
    cmd_sync

    echo -e "${GREEN}[OK] Full System Update Complete!${NC}"
}

cmd_web() {
    local PORT=8080
    local MODE="simple"

    # Argument Parsing
    for arg in "$@"; do
        if [ "$arg" == "--session" ]; then
            MODE="session"
        elif [ "$arg" == "--simple" ] && [ "$MODE" != "session" ]; then
            MODE="simple"
        elif [[ "$arg" =~ ^[0-9]+$ ]]; then
            PORT=$arg
        fi
    done

    # 1. Critical Dependency Check
    local critical_deps=("ttyd")
    if [ "$MODE" != "simple" ]; then
        critical_deps+=("tmux")
    fi
    # Dashboard apps are optional/fallback-capable
    
    local missing_critical=()
    for dep in "${critical_deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_critical+=("$dep")
        fi
    done

    if [ ${#missing_critical[@]} -gt 0 ]; then
        echo -e "${BLUE}[-] Refreshing package lists...${NC}"
        pkg update -y &>/dev/null
        echo -e "${BLUE}[-] Installing dependencies (${missing_critical[*]})...${NC}"
        if ! pkg install -y "${missing_critical[@]}" &>/dev/null; then
            echo -e "${RED}[ERR] Failed to install dependencies. Check your internet connection.${NC}"
            return 1
        fi
    fi



    # 3. Wake Lock
    if command -v termux-wake-lock &> /dev/null; then
        termux-wake-lock
    fi

    # 3. IP Detection
    local IP=$(ifconfig 2>/dev/null | grep -A 1 'wlan0' | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
    if [ -z "$IP" ]; then
        IP=$(ifconfig 2>/dev/null | grep 'inet 192.168' | head -n 1 | awk '{print $2}' | cut -d/ -f1)
    fi
    if [ -z "$IP" ]; then IP="localhost"; fi

    # 4. Auth
    echo -e "${PURPLE}Set a password for web access [Enter for random]:${NC}"
    read -r -s PASSWORD
    if [ -z "$PASSWORD" ]; then
        PASSWORD=$((1000 + RANDOM % 8999))
        echo -e "Using random password: ${YELLOW}$PASSWORD${NC}"
    fi

    # 5. Execution
    local FISH_BIN=$(command -v fish)
    local TMUX_BIN=$(command -v tmux)
    local BASH_BIN=$(command -v bash)

    echo -e "\n${GREEN}🚀 Web Terminal Active!${NC}"
    echo -e "🔗 URL:  ${CYAN}http://$IP:$PORT${NC}"
    echo -e "🔐 Creds: user: ${YELLOW}tb${NC} / pass: ${YELLOW}$PASSWORD${NC}"
    echo -e "${BLUE}(Press Ctrl+C to stop)${NC}"

    # Trap to cleanup
    trap "termux-wake-unlock; echo -e '\nStopped.'; exit" INT TERM

    # Export variables
    export TERM=xterm-256color
    export TB_WEB_MODE=1

    # TTYD Options
    local TTYD_OPTS="-t rendererType=canvas,cursorBlink=true,disableStdin=false"

    if [ "$MODE" == "simple" ]; then
        # Simple Mode: Direct Shell
        ttyd --writable -p $PORT -c "tb:$PASSWORD" $TTYD_OPTS "$FISH_BIN"
    else
        # Persistent Modes
        local SESSION_NAME=""
        
        # Persistent Mode (Standard Session)
        SESSION_NAME="tb_session_$PORT"
        echo -e "${YELLOW}[i] Session: $SESSION_NAME${NC}"
        
        # Create session if not exists
        if ! "$TMUX_BIN" has-session -t "$SESSION_NAME" 2>/dev/null; then
            "$TMUX_BIN" new-session -d -s "$SESSION_NAME" "$BASH_BIN -c 'export TERM=xterm-256color TB_WEB_MODE=1; exec $FISH_BIN'"
        fi

        # Configure Settings (Always Apply)
        "$TMUX_BIN" set -g mouse on 2>/dev/null
        "$TMUX_BIN" set-option -t "$SESSION_NAME" status-style "bg=black,fg=white" 2>/dev/null
        "$TMUX_BIN" set-option -t "$SESSION_NAME" status-left "#[fg=green,bold] TB Session #[default]" 2>/dev/null
        "$TMUX_BIN" set-option -t "$SESSION_NAME" status-right "#[fg=cyan]New: ^B c #[fg=red]| #[fg=cyan]Close: ^B x #[fg=red]| #[fg=cyan]Switch: ^B n/p " 2>/dev/null
        "$TMUX_BIN" set-option -t "$SESSION_NAME" status-right-length 80 2>/dev/null

        # Run ttyd attaching to the specific session
        ttyd --writable -p $PORT -c "tb:$PASSWORD" $TTYD_OPTS "$TMUX_BIN" attach-session -t "$SESSION_NAME"
    fi
}

cmd_help() {
    echo -e "\n${PURPLE}============================================${NC}"
    echo -e "${PURPLE}       TERMUX BOOTSTRAP SHORTCUTS           ${NC}"
    echo -e "${PURPLE}============================================${NC}"
    
    echo -e "${GREEN}[Media]${NC}"
    echo -e "  ${CYAN}video${NC}   : Download video to /sdcard/Download"
    echo -e "  ${CYAN}music${NC}   : Smart Spotify download (+Lyrics/LRC)"
    
    echo -e "\n${GREEN}[AI]${NC}"
    echo -e "  ${CYAN}whisper${NC} : AI Speech-to-Text (Offline)"
    echo -e "  ${CYAN}ask${NC}     : Ask AI (Supports piping: echo '...' | ask 'Summary')"
    
    echo -e "\n${GREEN}[Git]${NC}"
    echo -e "  ${CYAN}g${NC}       : git shortcut"
    echo -e "  ${CYAN}gl${NC}      : Pretty, narrow git log for mobile"
    
    echo -e "\n${GREEN}[System]${NC}"
    echo -e "  ${CYAN}up${NC}      : pkg update && upgrade"
    echo -e "  ${CYAN}in${NC}      : pkg install"
    echo -e "  ${CYAN}open${NC}    : Open file in Android app"
    echo -e "  ${CYAN}serve${NC}   : Start web server in current dir"
    echo -e "  ${CYAN}copy${NC}    : Pipe to Android clipboard"
    echo -e "  ${CYAN}paste${NC}   : Paste from Android clipboard"
    echo -e "  ${CYAN}c${NC}       : Clear screen"
    
    echo -e "\n${GREEN}[CLI Manager]${NC}"
    echo -e "  ${CYAN}tb web${NC}    : Web Terminal (--session)"
    echo -e "  ${CYAN}tb sync${NC}   : Sync Bootstrap scripts only"
    echo -e "  ${CYAN}tb update${NC} : Full System Update (Pkg, Pip, Npm, etc)"
    echo -e "  ${CYAN}tb theme${NC}  : Change terminal color scheme"
    echo -e "  ${CYAN}tb help${NC}   : Show this guide"
    
    echo -e "\n${YELLOW}Tip: Type 'tb <command>' to manage your environment.${NC}\n"
}

# --- Main Dispatch ---

case "$1" in
    update)
        cmd_update
        ;;
    sync)
        cmd_sync
        ;;
    web)
        cmd_web "$@"
        ;;
    theme)
        cmd_theme
        ;;
    help|*)
        cmd_help
        ;;
esac
