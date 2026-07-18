#!/usr/bin/env bash
#
# install.sh — Automated dotfiles installation for Arch Linux
# Repository: https://github.com/zaid/mydotfiles
#
# Usage:
#   ./install.sh
#
# Features:
#   - Interactive TUI menu with Nerd Font icons
#   - Pacman & AUR package installation (per-package error handling)
#   - Auto-builds yay-bin if AUR helper not found
#   - Timestamped backup before dotfile deployment
#   - Sudo credential caching with keepalive
# =============================================================================

set -o nounset
# NO 'set -e' — handle errors per-operation, never crash the full script

# =============================================================================
# --- Configuration
# =============================================================================
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKGLIST="$DOTFILES_DIR/pkglist.txt"
AURLIST="$DOTFILES_DIR/aurlist.txt"
VERSION="1.0.0"

# Config directories — each has a .config/ subdir synced to ~/.config/
CONFIG_DIRS=(
    btop
    fastfetch
    ghostty
    icons
    nvim
    opencode
    plank
    rofi
    starship
    themes
    xfce
)

# Home dotfiles — single files synced to ~/
HOME_FILES=(
    "tmux/.tmux.conf"
    "wezterm/.wezterm.lua"
    "zsh/.zshrc"
)

# Backgrounds destination
BG_SRC="$DOTFILES_DIR/Backgrounds"
BG_DST="$HOME/Pictures/Backgrounds"

# Exclude patterns for rsync
RSYNC_EXCLUDES=(
    ".zshrc.backup"
)

# =============================================================================
# --- Colors & Icons
# =============================================================================
readonly RESET='\033[0m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'

readonly BLACK='\033[0;30m'
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[0;37m'

# Nerd Font icons
ICON_ARCH=$'\uf0c3'
ICON_CHECK=$'\uf00c'
ICON_CROSS=$'\uf00d'
ICON_WARN=$'\uf071'
ICON_INFO=$'\uf05a'
ICON_GEAR=$'\uf013'
ICON_PACKAGE=$'\uf0c5'
ICON_FOLDER=$'\uf07c'
ICON_USER=$'\uf007'
ICON_DOWNLOAD=$'\uf019'
ICON_HOME=$'\uf015'
ICON_BOLT=$'\uf0e7'

# =============================================================================
# --- Logging Helpers
# =============================================================================
log()       { echo -e "${BOLD}$1${RESET} $2"; }
log_info()  { log "${BLUE}${ICON_INFO}${RESET}" "${BOLD}$1${RESET}"; }
log_ok()    { log "${GREEN}${ICON_CHECK}${RESET}" "${BOLD}$1${RESET}"; }
log_warn()  { log "${YELLOW}${ICON_WARN}${RESET}" "${BOLD}$1${RESET}"; }
log_fail()  { log "${RED}${ICON_CROSS}${RESET}" "${BOLD}$1${RESET}"; }
log_step()  { echo -e "\n  ${BOLD}${CYAN}${ICON_BOLT}${RESET} ${BOLD}$1${RESET}"; }
log_title() { echo -e "\n${BOLD}${CYAN}── $1 ──${RESET}\n"; }
log_separator() { echo -e "${DIM}────────────────────────────────────────${RESET}"; }

# =============================================================================
# --- Print Banner
# =============================================================================
print_banner() {
    echo -e "${BOLD}${CYAN}"
    echo "  ╔══════════════════════════════════════════════════════════════╗"
    echo "  ║    ${ICON_ARCH}  Arch Linux Dotfiles Installer  ${ICON_ARCH} ║"
    echo "  ║             Automated Deployment Tool  v${VERSION}           ║"
    echo "  ╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

# =============================================================================
# --- Print Menu
# =============================================================================
print_menu() {
    echo -e "  ${BOLD}${WHITE}Select an operation:${RESET}\n"
    echo -e "  ${BOLD}${CYAN}[1]${RESET} ${ICON_GEAR}  Full Install       ${DIM}(Pacman + AUR + Dotfiles)${RESET}"
    echo -e "  ${BOLD}${CYAN}[2]${RESET} ${ICON_PACKAGE}  Pacman Packages    ${DIM}(pkglist.txt only)${RESET}"
    echo -e "  ${BOLD}${CYAN}[3]${RESET} ${ICON_DOWNLOAD}  AUR Packages       ${DIM}(aurlist.txt only)${RESET}"
    echo -e "  ${BOLD}${CYAN}[4]${RESET} ${ICON_FOLDER}  Deploy Dotfiles    ${DIM}(backup + rsync)${RESET}"
    echo -e "  ${BOLD}${CYAN}[5]${RESET} ${ICON_CROSS}  Exit"
}

# =============================================================================
# --- Pre-checks
# =============================================================================
pre_checks() {
    local issues=0

    # Check we are on a pacman-based system
    if ! command -v pacman &>/dev/null; then
        log_fail "pacman not found. This script is for Arch Linux only."
        exit 1
    fi

    # Check script is not run as root
    if [[ $EUID -eq 0 ]]; then
        log_warn "Running as root is not recommended. The script will use sudo when needed."
        log_info "If you proceed, dotfiles will deploy to /root/ instead of your user home."
        echo ""
        read -r -p "  Continue as root? [y/N] " reply
        if [[ ! "$reply" =~ ^[Yy]$ ]]; then
            log_info "Exiting. Run again as a normal user."
            exit 0
        fi
    fi

    # Warn if pkglist.txt missing
    if [[ ! -f "$PKGLIST" ]]; then
        log_warn "pkglist.txt not found — Pacman packages will be skipped."
        issues=$((issues + 1))
    fi

    # Warn if aurlist.txt missing
    if [[ ! -f "$AURLIST" ]]; then
        log_warn "aurlist.txt not found — AUR packages will be skipped."
        issues=$((issues + 1))
    fi

    # Check for rsync
    if ! command -v rsync &>/dev/null; then
        log_warn "rsync not found. Dotfiles deployment will use cp instead."
        issues=$((issues + 1))
    fi

    if [[ $issues -gt 0 ]]; then
        echo ""
        log_info "Some checks flagged warnings above. Continuing anyway..."
    else
        log_ok "All pre-checks passed"
    fi
}

# =============================================================================
# --- Sudo Credential Caching
# =============================================================================
SUDO_PID=""

sudo_refresh() {
    log_step "Caching sudo credentials..."
    sudo -v 2>&1 || {
        log_fail "sudo authentication failed."
        exit 1
    }
    # Keep sudo timestamp fresh in background
    while true; do
        sudo -n true 2>/dev/null
        sleep 60
    done &
    SUDO_PID=$!
    log_ok "sudo credentials cached (keepalive active)"
}

# =============================================================================
# --- Cleanup on Exit
# =============================================================================
cleanup() {
    if [[ -n "$SUDO_PID" ]]; then
        kill "$SUDO_PID" 2>/dev/null || true
    fi
    echo ""
    log_info "Cleanup complete."
}

trap cleanup EXIT INT TERM

# =============================================================================
# --- Pause Helper
# =============================================================================
pause() {
    echo ""
    read -r -p "  Press Enter to return to menu..."
}

# =============================================================================
# --- Ensure yay is Installed
# =============================================================================
ensure_yay() {
    if command -v yay &>/dev/null; then
        return 0
    fi

    log_warn "yay not found. Installing yay-bin from AUR..."
    log_separator

    # Ensure git and base-devel are available
    local deps_ok=true
    if ! command -v git &>/dev/null; then
        log_info "Installing git..."
        sudo pacman -S --noconfirm git 2>/dev/null || deps_ok=false
    fi
    if ! pacman -Qg base-devel &>/dev/null; then
        log_info "Installing base-devel..."
        sudo pacman -S --needed --noconfirm base-devel 2>/dev/null || deps_ok=false
    fi
    if ! $deps_ok; then
        log_fail "Failed to install build dependencies for yay."
        return 1
    fi

    local tmpdir="/tmp/yay-bin"
    [[ -d "$tmpdir" ]] && rm -rf "$tmpdir"

    log_info "Cloning yay-bin to $tmpdir ..."
    if ! git clone --depth=1 "https://aur.archlinux.org/yay-bin.git" "$tmpdir" 2>/dev/null; then
        log_fail "Failed to clone yay-bin repository."
        return 1
    fi

    log_info "Building yay-bin (this may take a while)..."
    if ! (cd "$tmpdir" && makepkg -si --noconfirm) 2>/dev/null; then
        log_fail "Failed to build yay-bin. Check build output above."
        rm -rf "$tmpdir"
        return 1
    fi

    rm -rf "$tmpdir"
    log_ok "yay installed successfully"
}

# =============================================================================
# --- Install Pacman Packages
# =============================================================================
install_pacman() {
    if [[ ! -f "$PKGLIST" ]]; then
        log_warn "pkglist.txt not found. Skipping Pacman packages."
        return
    fi

    log_title "${ICON_PACKAGE} Installing Pacman Packages"
    log_separator

    local total=0
    local succeeded=0
    local failed=0

    while IFS= read -r pkg || [[ -n "$pkg" ]]; do
        # Strip whitespace, skip blanks and comments
        pkg="${pkg#"${pkg%%[![:space:]]*}"}"
        pkg="${pkg%"${pkg##*[![:space:]]}"}"
        [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue

        total=$((total + 1))
        echo -ne "  ${BOLD}${BLUE}▸${RESET} Installing ${BOLD}$pkg${RESET} ... "

        if sudo pacman -S --noconfirm "$pkg" &>/dev/null; then
            echo -e "${GREEN}${ICON_CHECK}${RESET}"
            succeeded=$((succeeded + 1))
        else
            echo -e "${RED}${ICON_CROSS}${RESET} ${DIM}skipping${RESET}"
            failed=$((failed + 1))
        fi
    done < "$PKGLIST"

    echo ""
    log_separator
    log_info "Pacman: $succeeded installed, $failed failed out of $total packages"
}

# =============================================================================
# --- Install AUR Packages
# =============================================================================
install_aur() {
    if [[ ! -f "$AURLIST" ]]; then
        log_warn "aurlist.txt not found. Skipping AUR packages."
        return
    fi

    # Check if file is non-empty (after comments/blanks)
    if ! grep -qvE '^\s*(#|$)' "$AURLIST" 2>/dev/null; then
        log_info "aurlist.txt is empty. Skipping."
        return
    fi

    log_title "${ICON_DOWNLOAD} Installing AUR Packages"
    log_separator

    ensure_yay || {
        log_fail "Cannot install AUR packages without yay."
        return
    }

    local total=0
    local succeeded=0
    local failed=0

    while IFS= read -r pkg || [[ -n "$pkg" ]]; do
        pkg="${pkg#"${pkg%%[![:space:]]*}"}"
        pkg="${pkg%"${pkg##*[![:space:]]}"}"
        [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue

        total=$((total + 1))
        echo -ne "  ${BOLD}${BLUE}▸${RESET} Installing ${BOLD}$pkg${RESET} ... "

        if yay -S --noconfirm "$pkg" &>/dev/null; then
            echo -e "${GREEN}${ICON_CHECK}${RESET}"
            succeeded=$((succeeded + 1))
        else
            echo -e "${RED}${ICON_CROSS}${RESET} ${DIM}skipping${RESET}"
            failed=$((failed + 1))
        fi
    done < "$AURLIST"

    echo ""
    log_separator
    log_info "AUR: $succeeded installed, $failed failed out of $total packages"
}

# =============================================================================
# --- Backup a Single File or Directory
# =============================================================================
backup_item() {
    local path="$1"
    local ts
    ts=$(date +%s)

    if [[ -e "$path" ]]; then
        local backup_path="${path}.bak.${ts}"
        if mv "$path" "$backup_path" 2>/dev/null; then
            log_info "Backed up: ${path/$HOME/\~} → ${backup_path/$HOME/\~}"
            return 0
        fi
    fi
    return 1
}

# =============================================================================
# --- Deploy Dotfiles
# =============================================================================
deploy_dotfiles() {
    log_title "${ICON_FOLDER} Deploying Dotfiles"
    log_separator

    # ---- .config directories ----
    log_step "Syncing .config directories"
    for dir in "${CONFIG_DIRS[@]}"; do
        local src="$DOTFILES_DIR/$dir/.config"
        local dst="$HOME/.config"

        if [[ ! -d "$src" ]]; then
            log_warn "Source not found: $dir/.config — skipping"
            continue
        fi

        # Backup each existing destination item before rsync
        shopt -s nullglob
        local items=("$src"/* "$src"/.*)
        shopt -u nullglob

        for item in "${items[@]}"; do
            [[ -e "$item" ]] || continue
            local base
            base=$(basename "$item")
            [[ "$base" == "." || "$base" == ".." ]] && continue
            backup_item "$dst/$base"
        done

        # Deploy
        mkdir -p "$dst"
        if command -v rsync &>/dev/null; then
            rsync -avh --exclude='.zshrc.backup' "$src/" "$dst/" | sed 's/^/  /'
        else
            cp -r -- "$src/"* "$dst/" 2>/dev/null
            # Handle dotfiles in .config (e.g., .icons, .themes)
            for item in "$src"/.*; do
                base=$(basename "$item")
                [[ "$base" == "." || "$base" == ".." ]] && continue
                cp -r "$item" "$dst/" 2>/dev/null || true
            done
        fi
        log_ok "${BOLD}$dir${RESET} deployed to ~/.config/"
    done

    # ---- Home dotfiles ----
    log_step "Syncing home dotfiles"
    for entry in "${HOME_FILES[@]}"; do
        local src_file="$DOTFILES_DIR/$entry"
        local filename
        filename=$(basename "$entry")
        local dst_file="$HOME/$filename"

        if [[ ! -f "$src_file" ]]; then
            log_warn "Source not found: $entry — skipping"
            continue
        fi

        backup_item "$dst_file"

        if command -v rsync &>/dev/null; then
            rsync -avh "$src_file" "$dst_file" | sed 's/^/  /'
        else
            cp -r "$src_file" "$dst_file"
        fi
        log_ok "Deployed ~/$filename"
    done

    # ---- Backgrounds ----
    log_step "Syncing Backgrounds"
    if [[ -d "$BG_SRC" ]]; then
        backup_item "$BG_DST"
        mkdir -p "$(dirname "$BG_DST")"
        if command -v rsync &>/dev/null; then
            rsync -avh "$BG_SRC/" "$BG_DST/" | sed 's/^/  /'
        else
            mkdir -p "$BG_DST"
            cp -r "$BG_SRC/"* "$BG_DST/" 2>/dev/null || true
        fi
        log_ok "Backgrounds deployed to ~/Pictures/Backgrounds/"
    else
        log_info "Backgrounds/ directory not found — skipping"
    fi

    echo ""
    log_separator
    log_ok "Dotfiles deployment complete"
}

# =============================================================================
# --- Full Install
# =============================================================================
full_install() {
    echo ""
    log_warn "Starting Full Install — this will install packages and deploy dotfiles."
    echo ""
    read -r -p "  Continue with Full Install? [y/N] " reply
    if [[ ! "$reply" =~ ^[Yy]$ ]]; then
        log_info "Full Install cancelled."
        return
    fi

    sudo_refresh
    pre_checks
    install_pacman
    echo ""
    install_aur
    echo ""
    deploy_dotfiles
    echo ""
    log_ok "Full Install complete!"
}

# =============================================================================
# --- Main Menu Loop
# =============================================================================
main() {
    while true; do
        clear
        print_banner
        pre_checks
        echo ""
        print_menu
        echo ""
        read -r -p "  Enter your choice [1-5]: " choice

        case "$choice" in
            1)
                full_install
                pause
                ;;
            2)
                sudo_refresh
                install_pacman
                pause
                ;;
            3)
                install_aur
                pause
                ;;
            4)
                deploy_dotfiles
                pause
                ;;
            5)
                echo ""
                log_ok "Goodbye ${ICON_ARCH}"
                exit 0
                ;;
            *)
                echo -e "\n  ${RED}${ICON_CROSS}${RESET} ${BOLD}Invalid option. Please enter 1-5.${RESET}"
                sleep 1
                ;;
        esac
    done
}

# =============================================================================
# --- Entry Point
# =============================================================================
main
