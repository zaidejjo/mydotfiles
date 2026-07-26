# Zaid Ajo's Fast ZSH Config (Zinit Powered)
# zmodload zsh/zprof

eval "$(starship init zsh)"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# --- Zinit Bootstrapping ---
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d "$ZINIT_HOME" ] && mkdir -p "$(dirname $ZINIT_HOME)" && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"


# --- 2. تحميل إضافات Zinit مع الترتيب الصحيح لـ fzf-tab ---
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
# zinit ice Aloxaf/fzf-tab
zinit light Aloxaf/fzf-tab

# --- 3. باقي الإضافات بوضع Turbo السريع ---
zinit wait lucid light-mode for \
    atinit"ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)" \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-history-substring-search

# --- 4. snippets من OMZ ---
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::uv
zinit snippet OMZP::command-not-found
zinit snippet OMZP::bun

autoload -Uz compinit
compinit -C -d "${ZDOTDIR:-$HOME}/.zcompdump"

zinit cdreplay -q

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# zstyle ':completion:*:*:dj:*' fil-patterns ''
zstyle ':completion:*' menu no

# --- fzf-tab Configuration ---
zstyle ':fzf-tab:*' fzf-flags \
  --color=bg+:#313244,bg:#1e1e2e,spinner:#b4befe,hl:#cba6f7 \
  --color=fg:#cdd6f4,header:#cba6f7,info:#89b4fa,pointer:#b4befe \
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#cba6f7 \
  --color=border:#b4befe,label:#cba6f7 \
  --border=sharp \
  --padding=1 \
  --prompt='󰍉  ' \
  --pointer='❯ '

zstyle ':fzf-tab:*' switch-group ',' '.'

# المعاينة في الأسفل بدلاً من اليمين لتصميم أروق
zstyle ':fzf-tab:*' fzf-preview-window 'down:50%:wrap'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --color=always --icons=always $realpath'

# --- Secrets ---
[ -f ~/.pypi_secrets ] && source ~/.pypi_secrets
[ -f ~/.secrets ] && source ~/.secrets

export EDITOR='nvim'
alias snvim="sudoedit"
export VISUAL='nvim'
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
export TERMINAL="wezterm"

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
--layout=reverse \
--height=60% \
--border='sharp' \
--margin=1 \
--padding=1 \
--color=bg+:#313244,bg:#1e1e2e,spinner:#b4befe,hl:#cba6f7 \
--color=fg:#cdd6f4,header:#cba6f7,info:#89b4fa,pointer:#b4befe \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#cba6f7 \
--color=border:#b4befe,label:#89b4fa \
--border-label=' 󰍉 FIND ' --border-label-pos=2 \
--prompt='❯ ' --pointer='❯ ' --marker='✔ ' "

smart_preview="if [ -d {} ]; then eza --tree --color=always --icons {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
show_file_or_dir_preview="if [ -d {} ]; then yazi --chooser-file=/dev/null {}; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$smart_preview' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons {} | head -200'"

bindkey '^H' backward-kill-word
bindkey '^[^[[3;5~' kill-word
bindkey '^Z' undo
bindkey "^[[1;5C" forward-word      # Ctrl + Right Arrow
bindkey "^[[1;5D" backward-word     # Ctrl + Left Arrow
bindkey "^[b" backward-word         # Alt + Left Arrow
bindkey "^[f" forward-word          # Alt + Right Arrow
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
alias la='eza -a --icons --color=always'
alias tree='eza -T'
alias cat='bat --paging=never'
alias jl='jupyter-lab'
# alias fref='nvim $(rg --line-number --column --no-heading --color=always --smart-case . | fzf --ansi --delimiter : --preview "bat --color=always --highlight-line {2} {1}" | cut -d: -f1,2 | sed "s/:/ +/")'
# alias fcp='fzf --preview "bat --color=always {}" | xclip -selection clipboard'
alias lg='lazygit'

# --- UV & Python Optimized ---
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

# git
alias gcm='git switch main'
alias gcd='git switch dev'
alias gw='git switch'
alias gcrag='git switch feature/faiss-rag'

# NVChad
alias nvchad="NVIM_APPNAME=nvchad nvim"

# Wifi
alias wifi='wlctl'

# Media
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
# --- Ultimate Nushell Directory View & Smart Navigation (cx) ---
cx() {
  # 1. دعم zoxide للقفز الذكي بين المجلدات
  if [ -n "$1" ]; then
    if [ -d "$1" ]; then
      builtin cd "$1" || return
    elif command -v zoxide >/dev/null 2>&1; then
      local target_dir
      target_dir="$(zoxide query "$1" 2>/dev/null)"
      if [ -n "$target_dir" ] && [ -d "$target_dir" ]; then
        builtin cd "$target_dir" || return
      else
        echo "Directory not found: $1"
        return 1
      fi
    else
      builtin cd "$1" || return
    fi
  fi

  # 2. Nushell Table Generator مع الأيقونات والتصفيف الأنيق
  nu -c "
    ls 
    | sort-by type name 
    | insert icon {|row| if \$row.type == 'dir' { '' } else { '' }}
    | update name {|row| $'(\$row.icon)(\$row.name)'}
    | update size {|row| if \$row.type == 'dir' { '' } else { \$row.size }}
    | reject icon
  "
}
# ---  History ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

[ -f ~/.thefuck_init.zsh ] && source ~/.thefuck_init.zsh

export BAT_THEME="Catppuccin Mocha"

autoload -Uz edit-command-line
zle -N edit-command-line

vact() {
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
