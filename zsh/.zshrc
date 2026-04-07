# ~/.zshrc: نسخة منظمة وسريعة

# --------- Theme ----------
# jonathan
ZSH_THEME="af-magic"

# --------- فقط للتفاعلي ----------
[[ -o interactive ]] || return



# --------- Aliases سريعة للنظام ----------
alias ؤمس='clear'
alias cls='clear'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias meminfo='free -h'
alias cpuinfo='lscpu'
alias dfh='df -h'
alias top10='top -o %MEM | head -n 12'
alias jl='jupyter-lab'

# --------- Zsh completion + plugins ----------
autoload -Uz compinit
compinit -u          # ignore unsafe files
plugins=(git zsh-autosuggestions zsh-syntax-highlighting history-substring-search sudo fzf-tab)
setopt auto_menu      # Tab يفتح menu للتكملة

# --------- History محسّن ----------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt append_history
setopt share_history
setopt inc_append_history
setopt hist_ignore_dups
setopt hist_reduce_blanks

# --------- Git branch helper ----------
parse_git_branch() { git rev-parse --abbrev-ref HEAD 2>/dev/null }

# --------- oh-my-zsh ----------
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true
source $ZSH/oh-my-zsh.sh

# --------- NVM ----------
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"


# --------- Git Aliases ----------
alias gt='git status'
alias gl='git log --oneline --graph --decorate --all'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -v'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gba='git branch -a'

# --------- PATHs ----------
export PATH=$HOME/.local/bin:$PATH
export PATH=/opt/cmake/bin:$PATH

alias python=python3.12
alias py=python3.12
alias update='sudo apt update && sudo apt upgrade -y'
alias clean='sudo apt autoremove -y && sudo apt autoclean'

# --------- C++ Run and Compile function ----------
crun () {
    g++ -std=c++17 "$1" -o "${1%.cpp}" && "./${1%.cpp}"
}

# --------Django shortcauts --------
alias runserver='python manage.py runserver'
alias urunserver='uv run python manage.py runserver'
alias check='python manage.py check'
alias dshell='python manage.py shell'
alias makemig='python manage.py makemigrations'
alias mig='python manage.py migrate'
alias colstc='python manage.py collectstatic'
alias crtuser='python manage.py createsuperuser'
alias crtapp='python manage.py startapp'

alias sr='rg'
alias bat='batcat'
alias cat='batcat --paging=never'
alias fd='fdfind'
alias act='source .venv/bin/activate'
alias mkvenv='virtualenv'
alias taalomi='cd Taalomi-fi-yadi/school_portal/'
alias spsql='sudo systemctl start postgresql'

export PATH="$HOME/.npm-global/bin:$PATH"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"


alias nsch='nvim $(fzf --preview="batcat --color=always {}")'
alias zsch='zed $(fzf --preview="batcat --color=always {}")'
alias v='nvim'


fif() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  rg --files-with-matches --no-messages "$1" | \
    fzf --preview "rg --ignore-case --pretty --context 10 '$1' {}" \
        --bind "enter:execute(nvim {})"
}

rgnvim() {
  local selected file line
  selected=$(rg "$1" | fzf) || return
  file=$(echo "$selected" | cut -d: -f1)
  line=$(echo "$selected" | cut -d: -f2)
  nvim +"$line" "$file"
}

rgzed() {
  local selected file line
  selected=$(rg --vimgrep "$*" | fzf) || return
  file=$(printf '%s\n' "$selected" | awk -F: '{print $1}')
  line=$(printf '%s\n' "$selected" | awk -F: '{print $2}')
  zed -- "$file:$line"
}

zf() {
  local file
  file=$(fd . | fzf) || return
  zed "$file"
}

fh() {
  history | fzf
}

fhi() {
local cmd
  cmd=$(history | fzf | sed 's/^[ ]*[0-9]\+[ ]*//') || return
  eval "$cmd"
}


venvnear() {
  local venv
  venv=$(
    find . .. -type d \( -name venv -o -name .venv \) 2>/dev/null |
    awk '!seen[$0]++' |
    sort |
    fzf --prompt="Select venv > "
  ) || return
  source "$venv/bin/activate"
}

# ===== LS with exa =====
alias ls='eza --icons --color=always --group-directories-first'
alias ll='eza -alh --icons --color=always --group-directories-first --git'
alias la='eza -a --icons --color=always'
alias tree='eza -T'
alias sai='sudo apt install'
alias rm='trash-put'
# # Auto-start tmux
# if command -v tmux >/dev/null 2>&1; then
#   if [ -z "$TMUX" ]; then
#     tmux attach -t main || tmux new -s main
#   fi
# fi
#
alias copy='xsel --input --clipboard'
alias paste='xsel --output --clipboard'
alias reload='source ~/.zshrc'

# --------- حذف كلمة أو Undo ----------
bindkey '^H' backward-kill-word       # Ctrl+Backspace
bindkey '^[^[[3;5~' kill-word         # Ctrl+Delete
bindkey '^Z' undo                      # Ctrl+Z = Undo للسطر الحالي




[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# إعدادات ألوان fzf-tab (اختياري لكنه يجعله أجمل)
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' fzf-preview 'eza --icons --color=always $realpath'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always $realpath'

# 1. أولاً: تعريف المسارات (PATHs) ليعرف النظام أين توجد البرامج
export PATH="$HOME/.local/bin:$PATH"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# 2. ثانياً: تفعيل thefuck (بعد التأكد أن المسارات أصبحت معروفة)
if command -v thefuck >/dev/null 2>&1; then
    eval "$(thefuck --alias)"
    eval "$(thefuck --alias fuck)"
fi

eval "$(thefuck --alias)"
eval "$(thefuck --alias fk)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

eval $(thefuck --alias)
export BAT_THEME="Catppuccin Mocha"

fastfetch
