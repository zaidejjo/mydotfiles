# Zaid Ajo's ZSH CONFIG

[[ -o interactive ]] || return

# تسريع تشغيل التحميل
autoload -Uz compinit && compinit -u

# 2. المسارات (Paths) - مجمعة في مكان واحد
export PATH="$HOME/.local/bin:/opt/cmake/bin:$HOME/.npm-global/bin:$PATH"
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

export EDITOR='nvim'
export VISUAL='nvim'
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"


# 3. الإضافات والثيم (Oh My Zsh & Starship)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="af-magic" # سيعلوه Starship لاحقاً
ZSH_DISABLE_COMPFIX=true
plugins=(git zsh-autosuggestions zsh-syntax-highlighting history-substring-search sudo fzf-tab)
source $ZSH/oh-my-zsh.sh

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#585b70"

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
# export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"# ألوان جذابة لـ FZF
# export FZF_DEFAULT_OPTS="--color=fg:#CBE0F0,bg:#011628,hl:#B388FF,fg+:#CBE0F0,bg+:#143652,hl+:#B388FF,info:#06BCE4,prompt:#2CF9ED,pointer:#2CF9ED,marker:#2CF9ED,spinner:#2CF9ED,header:#2CF9ED"

# --- Catppuccin Mocha for FZF ---
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
#
# export FZF_DEFAULT_OPTS="--height 60% --layout=reverse --border --margin=1 --padding=1 \
# --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
# --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
# --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
#
smart_preview="if [ -d {} ]; then eza --tree --color=always --icons {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
show_file_or_dir_preview="if [ -d {} ]; then yazi --chooser-file=/dev/null {}; else bat -n --color=always --line-range :500 {}; fi"
# show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$smart_preview' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons {} | head -200'"


bindkey '^H' backward-kill-word       # Ctrl+Backspace
bindkey '^[^[[3;5~' kill-word         # Ctrl+Delete
bindkey '^Z' undo                      # Ctrl+Z = Undo للسطر الحالي

# --- النظام ---
alias py='python3'
alias ؤمس='clear'
alias cls='clear'
alias ؤي='cd'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias update='sudo pacman -Syu'
alias clean='sudo apt autoremove -y && sudo apt autoclean'
alias ins='sudo pacman -S'
alias rm='trash-put'
alias reload='source ~/.zshrc'
alias v='nvim'
alias vf='fzf | xargs -r nvim'
alias nsch='nvim $(fzf --preview="bat --color=always {}")'
alias zsch='zed $(fzf --preview="bat --color=always {}")'
alias copy='xsel --input --clipboard'
alias paste='xsel --output --clipboard'

alias ls='eza --icons --color=always --group-directories-first'
alias ll='eza -alh --icons --color=always --group-directories-first --git'
alias la='eza -a --icons --color=always'
alias tree='eza -T'
alias cat='bat --paging=never'
alias jl='jupyter-lab'
alias fref='nvim $(rg --line-number --column --no-heading --color=always --smart-case . | fzf --ansi --delimiter : --preview "bat --color=always --highlight-line {2} {1}" | cut -d: -f1,2 | sed "s/:/ +/")'
alias fcp='fzf --preview "bat --color=always {}" | xclip -selection clipboard'


# --- البرمجة (Python, Django, C++) ---
alias runserver='python manage.py runserver'
alias urunserver='uv run python manage.py runserver'
alias makemig='python manage.py makemigrations'
alias mig='python manage.py migrate'
alias shell='python manage.py shell'
alias dbshell='python manage.py dbshell'
alias colstc='python manage.py collectstatic'

alias mkvenv='virtualenv'
alias spsql='sudo systemctl start postgresql'

crun () { g++ -std=c++17 "$1" -o "${1%.cpp}" && "./${1%.cpp}"; }

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}


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
fh() {
  history | fzf
}

fhi() {
local cmd
  cmd=$(history | fzf | sed 's/^[ ]*[0-9]\+[ ]*//') || return
  eval "$cmd"
}
cz() {
    local dir
    dir=$(zoxide query -l | fzf --reverse --height 40% --preview 'eza --tree --color=always {} | head -50')
    if [ -n "$dir" ]; then
        cd "$dir"
    fi
}
fwi() {
  local dev=$(nmcli -t -f device dev | grep '^wlp' | head -n1)
  local target=$(nmcli --colors yes dev wifi list | sed 1d | fzf --ansi --header "Select WiFi Network")
  if [ -n "$target" ]; then
    local ssid=$(echo "$target" | awk '{print $2}')
    nmcli dev wifi connect "$ssid" --ask
  fi
}
fa() {
  local alias=$(alias | fzf --header "Search Aliases")
  [ -n "$alias" ] && echo "$alias"
}
calc() {
    echo "scale=2; $*" | bc -l
}

fif() {
  # سنبدأ ببحث فارغ أو بكلمة مفتاحية إذا مررتها كـ Argument
  INITIAL_QUERY="${*:-}"
  
  # هذا الأمر هو "محرك" البحث الذي سيستدعيه fzf عند كل تغيير
  RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case"

  fzf --ansi --disabled --query "$INITIAL_QUERY" \
      --bind "start:reload:$RG_PREFIX {q}" \
      --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
      --delimiter : \
      --preview 'bat --color=always --style=numbers --highlight-line {2} {1}' \
      --preview-window 'up:60%:wrap' \
      --bind "enter:become(nvim {1} +{2})" \
      --header " ..." \
      --prompt "❯ "
}
# قفزة ذكية مع معاينة لمحتويات المجلد بشجرة ملفات
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


histsize=10000
savehist=10000
setopt share_history append_history inc_append_history hist_ignore_dups


if command -v thefuck >/dev/null 2>&1; then
    eval "$(thefuck --alias fk)"
fi
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export BAT_THEME="Catppuccin Mocha"

autoload -Uz edit-command-line
zle -N edit-command-line


unalias act 2>/dev/null
act() {
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



export FZF_CTRL_T_OPTS="
  --preview 'if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

_fzf_open_in_nvim() {
    # هنا تم استبدال bat بـ smart_preview لحل مشكلة المجلدات
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

eval "$(navi widget zsh)"

eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"

alias taalomi='dj school_portal'
export PATH="$HOME/bin:$PATH"

fastfetch
