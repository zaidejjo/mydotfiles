# Zaid Ajo's Fast ZSH Config (Zinit Powered)
# zmodload zsh/zprof

eval "$(starship init zsh)"

# --- Zinit Bootstrapping ---
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname $ZINIT_HOME)" && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# --- 1. تحميل compinit المدمج أولاً بشكل صريح ---
autoload -Uz compinit
compinit -C -d "${ZDOTDIR:-$HOME}/.zcompdump"

# --- 2. تحميل إضافات Zinit مع الترتيب الصحيح لـ fzf-tab ---
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
# zinit light trapd00r/LS_COLORS
# ضروري جداً لتثبيت fzf-tab بدون أخطاء _setup
zinit ice Aloxaf/fzf-tab
zinit light Aloxaf/fzf-tab

# --- 3. باقي الإضافات بوضع Turbo السريع ---
zinit wait lucid light-mode for \
    atinit"ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)" \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-history-substring-search


# zsh-users/zsh-syntax-highlighting \


# --- 4. snippets من OMZ ---
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::uv

# --- إعدادات completion ---
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*:*:dj:*' file-patterns ''
zstyle ':completion:*:*:dj:*' menu yes select
# --- تحسين ألوان وقوائم fzf-tab ---
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:*' fzf-flags --color=fg:15,bg:-1,hl:6 --style=full
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $extract_colors'

# --- الملفات السرية والبيئة ---
[ -f ~/.pypi_secrets ] && source ~/.pypi_secrets
[ -f ~/.secrets ] && source ~/.secrets

export EDITOR='nvim'
alias snvim="sudoedit"
export VISUAL='nvim'
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
export TERMINAL="wezterm"

# (كمل باقي الملف عادي من هون...)

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#585b70"

# --- FZF ---
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix \
    --exclude .git \
    --exclude .local \
    --exclude .cache \
    --exclude .npm \
    --exclude .cargo \
    --exclude .rustup \
    --exclude node_modules \
    --exclude .venv"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

export FZF_DEFAULT_OPTS=" \
--ansi \
--layout=reverse --height=70% --border='rounded' --margin=1,2 --padding=1 \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=border:#585b70,label:#fab387 \
--border-label='  Search ' --border-label-pos=2 \
--prompt='  ' --pointer=' ' --marker=' ' "

smart_preview="if [ -d {} ]; then eza --tree --color=always --icons {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
show_file_or_dir_preview="if [ -d {} ]; then yazi --chooser-file=/dev/null {}; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$smart_preview' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons {} | head -200'"

bindkey '^H' backward-kill-word
bindkey '^[^[[3;5~' kill-word
bindkey '^Z' undo
# إصلاح حركة الأسهم مع Ctrl للتنقل بين الكلمات داخل Zellij / Tmux / WezTerm
bindkey "^[[1;5C" forward-word      # Ctrl + Right Arrow
bindkey "^[[1;5D" backward-word     # Ctrl + Left Arrow
bindkey "^[b" backward-word         # Alt + Left Arrow
bindkey "^[f" forward-word          # Alt + Right Arrow

# إعدادات إضافية للتوافق مع بعض أنماط المحاكيات
bindkey "^[OD" backward-word
bindkey "^[OC" forward-word
bindkey "5D" backward-word
bindkey "5C" forward-word
# --- Aliases ---
alias ؤمس='clear'
alias cls='clear'
alias cl='clear'
alias ؤي='cd'
alias ..='cd ..'
alias .3='cd ../..'
alias .4='cd ../../..'
alias .5='cd ../../../..'
alias rm='trash-put'
alias reload='source ~/.zshrc'
alias v='nvim'
alias nano='nvim'
alias vf='fzf | xargs -r nvim'
alias nsch='nvim $(fzf --preview="bat --color=always {}")'
alias copy='xsel --input --clipboard'
alias paste='xsel --output --clipboard'

alias ls='eza --icons --color=always --group-directories-first'
alias ll='eza -alh --icons --color=always --group-directories-first --git'
alias la='eza -a --icons --color=always'
alias tree='eza -T'
alias cat='bat --paging=never'
alias jl='jupyter-lab'
# alias fref='nvim $(rg --line-number --column --no-heading --color=always --smart-case . | fzf --ansi --delimiter : --preview "bat --color=always --highlight-line {2} {1}" | cut -d: -f1,2 | sed "s/:/ +/")'
# alias fcp='fzf --preview "bat --color=always {}" | xclip -selection clipboard'
alias lg='lazygit'

# --- UV & Python Optimized ---
alias pip='uv pip'
alias venv='uv venv'
alias py='uv run python'
alias dj='uv run manage.py'
alias drun='uv run manage.py runserver 0.0.0.0:8000'
alias dmm='uv run manage.py makemigrations'
alias dms='uv run manage.py migrate_schemas'
alias dmig='uv run manage.py migrate'
alias dsh='uv run manage.py shell'
alias dbsh='uv run manage.py dbshell'
alias dcolstc='uv run manage.py collectstatic'
alias dcheck='uv run manage.py check'
alias runserver='python manage.py runserver'
alias spsql='sudo systemctl start postgresql'


alias wifi='wlctl'
alias mpvfl='mpv --loop-file=yes'
alias mpvpl='mpv --loop-playlist=inf'

_django_custom_completion() {
    local -a commands
    commands=(
        'runserver' 'makemigrations' 'migrate' 'shell' 
        'dbshell' 'collectstatic' 'createsuperuser' 
        'check' 'test' 'showmigrations'
    )
    _describe -t commands 'Django Commands' commands
}
compdef _django_custom_completion dj

crun () { g++ -std=c++17 "$1" -o "${1%.cpp}" && "./${1%.cpp}"; }

alias ytdl='yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4'
alias yt-up='sudo yt-dlp -U'
alias yt-playlist='yt-dlp -i -x --audio-format mp3 --yes-playlist'
alias ytmp3='yt-dlp --cookies-from-browser brave -x --audio-format mp3 --audio-quality 0 -o "%(title)s.%(ext)s"'

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }

# cx() {
#     local show_hidden=0
#     local target_dir="."
#
#     while [[ $# -gt 0 ]]; do
#         case "$1" in
#             -a) show_hidden=1; shift ;;
#             -*) shift ;;
#             *) target_dir="$1"; shift ;;
#         esac
#     done
#
#     if [ -d "$target_dir" ]; then
#         local original_dir="$PWD"
#         cd "$target_dir" || return
#     fi
#
#     echo -e "\e[1;36m┌─────┬────────────────────────────────┬──────────┬──────────────────┐\e[0m"
#     echo -e "\e[1;36m│ \e[1;33m#   \e[1;36m│ \e[1;33mName                            \e[1;36m│ \e[1;33mType     \e[1;36m│ \e[1;33mModified          \e[1;36m│\e[0m"
#     echo -e "\e[1;36m├─────┼────────────────────────────────┼──────────┼──────────────────┤\e[0m"
#
#     local i=1
#
#     if [ "$show_hidden" -eq 1 ]; then
#         (
#             find . -maxdepth 1 -mindepth 1 -type d ! -name '.' ! -name '..' | sort
#             find . -maxdepth 1 -mindepth 1 -type f | sort
#         )
#     else
#         (
#             find . -maxdepth 1 -mindepth 1 -type d ! -name '.*' | sort
#             find . -maxdepth 1 -mindepth 1 -type f ! -name '.*' | sort
#         )
#     fi |
#     while read -r entry; do
#         local name="${entry#./}"
#         [ -z "$name" ] && continue
#
#         local mod_time=""
#         if [ -d "$name" ] || [ -f "$name" ]; then
#             mod_time=$(date -r "$name" "+%d %b %H:%M" 2>/dev/null)
#             [ -z "$mod_time" ] && mod_time=$(stat -c '%y' "$name" 2>/dev/null | cut -c1-16)
#         fi
#         [ -z "$mod_time" ] && mod_time="---"
#
#         local type_str="File"
#         local is_dir=0
#         if [ -d "$name" ]; then
#             type_str="Dir"
#             is_dir=1
#         fi
#
#         awk -v idx="$i" -v name="$name" -v is_dir="$is_dir" -v type="$type_str" -v mtime="$mod_time" '
#         BEGIN {
#             color = (is_dir == 1) ? "\033[1;34m" : "\033[0;32m";
#             reset = "\033[0m";
#             cyan  = "\033[1;36m";
#             printf "%s│%s %-3s %s│%s %s%-30s%s %s│%s %-8s %s│%s %-16s %s│%s\n", \
#                    cyan, reset, idx, cyan, reset, color, name, reset, cyan, reset, type, cyan, reset, mtime, cyan, reset
#         }'
#
#         i=$((i+1))
#     done
#
#     echo -e "\e[1;36m└─────┴────────────────────────────────┴──────────┴──────────────────┘\e[0m"
#
#     if [ -n "$original_dir" ]; then
#         cd "$original_dir" || return
#     fi
# }


frg() {
  local rg_prefix="rg --column --line-number --no-heading --color=always --smart-case --glob '!.git/'"
  local initial_query="${*:-}"
  
  fzf --ansi --disabled --query "$initial_query" \
      --bind "start:reload:$rg_prefix {q}" \
      --bind "change:reload:sleep 0.1; $rg_prefix {q} || true" \
      --delimiter : \
      --preview 'bat --color=always --highlight-line {2} --style=numbers {1}' \
      --preview-window 'up,60%,border-bottom,+{2}+3/3' \
      --bind 'enter:become(nvim +{2} {1})'
}

fh() { history | fzf; }

fhi() {
  local cmd
  cmd=$(history | fzf | sed 's/^[ ]*[0-9]\+[ ]*//') || return
  eval "$cmd"
}

fwi() {
  local dev=$(nmcli -t -f device dev | grep '^wlp' | head -n1)
  local target=$(nmcli --colors yes dev wifi list | sed 1d | fzf --ansi --header "Select WiFi Network")
  if [ -n "$target" ]; then
    local ssid=$(echo "$target" | awk '{print $2}')
    nmcli dev wifi connect "$ssid" --ask
  fi
}

calc() { echo "scale=2; $*" | bc -l; }

# fif() {
#   INITIAL_QUERY="${*:-}"
#   RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case"
#
#   fzf --ansi --disabled --query "$INITIAL_QUERY" \
#       --bind "start:reload:$RG_PREFIX {q}" \
#       --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
#       --delimiter : \
#       --preview 'bat --color=always --style=numbers --highlight-line {2} {1}' \
#       --preview-window 'up:60%:wrap' \
#       --bind "enter:become(nvim {1} +{2})" \
#       --header " ..." \
#       --prompt "❯ "
# }

unalias zi 2>/dev/null
zi() {
  local dir
  dir=$(zoxide query -l | fzf --height 50% --layout=reverse --border --preview 'eza -T -L 2 --icons --color=always {} | head -20')
  if [ -n "$dir" ]; then
    cd "$dir"
  fi
}

killport() {
    if [ -z "$1" ]; then
        echo "Usage: killport <port>"
        return
    fi
    local pids=$(sudo lsof -t -i :$1 2>/dev/null)
    if [ -z "$pids" ]; then
        echo "No process using port $1"
        return
    fi
    echo "Killing processes on port $1:"
    echo $pids
    sudo kill -9 $(echo $pids)
    echo "Done"
}

mkcd() { mkdir -p "$1" && cd "$1"; }

histsize=10000
savehist=10000
setopt share_history append_history inc_append_history hist_ignore_dups

[ -f ~/.thefuck_init.zsh ] && source ~/.thefuck_init.zsh

export BAT_THEME="Catppuccin Mocha"

autoload -Uz edit-command-line
zle -N edit-command-line

unalias act 2>/dev/null
actv() {
  local dir="$PWD"
  while [ "$dir" != "/" ]; do
    for venv in .venv venv env; do
      if [ -d "$dir/$venv" ]; then
        source "$dir/$venv/bin/activate"
        echo "Activated: $dir/$venv"
        return
      fi
    done
    dir=$(dirname "$dir")
  done
  echo "No virtual environment found"
}

bindkey '^[e' edit-command-line
bindkey '^e' autosuggest-accept

_fzf_open_in_nvim() {
    local file=$(fd --hidden --strip-cwd-prefix --exclude .git | fzf --reverse --preview "$smart_preview")
    if [ -n "$file" ]; then
        if [ -d "$file" ]; then
            cd "$file"
            zle reset-prompt
        else
            zle -I
            nvim "$file"
            zle reset-prompt
        fi
    fi
}
zle -N _fzf_open_in_nvim
bindkey '^[p' _fzf_open_in_nvim

_fzf_history_enhanced() {
    local cmd=$(history -n 1 | fzf --tac --reverse --query="$LBUFFER" --prompt="History > ")
    if [ -n "$cmd" ]; then
        LBUFFER="$cmd"
    fi
    zle reset-prompt
}
zle -N _fzf_history_enhanced
bindkey '^[r' _fzf_history_enhanced

_fzf_grep_nvim() {
    local res=$(rg --column --line-number --no-heading --color=always --smart-case --glob '!.git/' "" | \
                fzf --ansi --delimiter : --preview 'bat --color=always --highlight-line {2} --style=numbers {1}' --preview-window 'up,60%')
    if [ -n "$res" ]; then
        local file=$(echo "$res" | cut -d: -f1)
        local line=$(echo "$res" | cut -d: -f2)
        zle -I
        nvim "+$line" "$file"
    fi
    zle reset-prompt
}
zle -N _fzf_grep_nvim
bindkey '^[t' _fzf_grep_nvim

[ -f ~/.navi_init.zsh ] && source ~/.navi_init.zsh
[ -f ~/.zoxide_init.zsh ] && source ~/.zoxide_init.zsh

# --- Zellij Autostart ---
#if [[ $- == *i* ]] && [ -z "$ZELLIJ" ] && [ -z "$TMUX" ]; then
#   if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
#       export TERM="xterm-256color"
#       exec zellij attach --create main
#   fi
#fi

# --- Tmux Autostart ---
if [[ $- == *i* ]] && [ -z "$ZELLIJ" ] && [ -z "$TMUX" ]; then
    if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
        export TERM="xterm-256color"
        exec tmux new-session -A -s main
    fi
fi
setxkbmap -option ctrl:nocaps

fastfetch


# PNPM & PATHs
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

alias gcm='git switch main'
alias gcd='git switch dev'
alias gw='git switch'
alias gcrag='git switch feature/faiss-rag'

alias odysseus="tmux new-session -d -s odysseus 'cd /home/zaid/odysseus && source venv/bin/activate && python -m uvicorn app:app --host 127.0.0.1 --port 7000'"
alias odysseus-stop="tmux kill-session -t odysseus"

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH="$PATH:$ANDROID_HOME/tools/bin"

export NVM_DIR="$HOME/.config/nvm"

_load_nvm() {
    unset -f nvm node npm npx yarn
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

nvm() { _load_nvm; nvm "$@"; }
node() { _load_nvm; node "$@"; }
npm() { _load_nvm; npm "$@"; }
npx() { _load_nvm; npx "$@"; }
yarn() { _load_nvm; yarn "$@"; }

export OPENCODE_EXPERIMENTAL_CACHE_STABILIZATION=1
export OPENCODE_CACHE_AUDIT=1
export OPENCODE_EXPERIMENTAL_CACHE_1H_TTL=1

export PATH="$HOME/bin:$PATH"
export PATH="/home/zaid/.local/bin:$PATH"

alias apt='sudo nala'

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/home/zaid/.bun/_bun" ] && source "/home/zaid/.bun/_bun"

alias bnmodule='bunx nuxi@latest module add'
alias pnmodule='pnx nuxi@latest module add'

[[ -e "/home/zaid/lib/oracle-cli/lib/python3.14/site-packages/oci_cli/bin/oci_autocomplete.sh" ]] && source "/home/zaid/lib/oracle-cli/lib/python3.14/site-packages/oci_cli/bin/oci_autocomplete.sh"
export PATH_NPM="$HOME/.npm-global/bin"
export PATH="$PATH:$PATH_NPM"
export PATH="$PATH:$HOME/flutter/bin"
export CHROME_EXECUTABLE=/usr/bin/brave


# zprof
export PATH="$HOME/go/bin:$PATH"
