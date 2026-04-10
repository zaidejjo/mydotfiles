#  ~/.zshrc - النسخة المحسنة والمنظمة

# 1. الإعدادات الأساسية والسرعة
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



# 3. الإضافات والثيم (Oh My Zsh & Starship)
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="af-magic" # سيعلوه Starship لاحقاً
ZSH_DISABLE_COMPFIX=true
plugins=(git zsh-autosuggestions zsh-syntax-highlighting history-substring-search sudo fzf-tab)
source $ZSH/oh-my-zsh.sh

# 4. إعدادات الـ FZF المتقدمة (الألوان والمعاينة)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_COMMAND="fdfind --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fdfind --type=d --hidden --strip-cwd-prefix --exclude .git"# ألوان جذابة لـ FZF
# export FZF_DEFAULT_OPTS="--color=fg:#CBE0F0,bg:#011628,hl:#B388FF,fg+:#CBE0F0,bg+:#143652,hl+:#B388FF,info:#06BCE4,prompt:#2CF9ED,pointer:#2CF9ED,marker:#2CF9ED,spinner:#2CF9ED,header:#2CF9ED"

# --- Catppuccin Mocha for FZF ---
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else batcat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
# أضف هذا السطر بعد سطر 37 مثلاً
bindkey '^P' fzf-file-widget
bindkey '^H' backward-kill-word       # Ctrl+Backspace
bindkey '^[^[[3;5~' kill-word         # Ctrl+Delete
bindkey '^Z' undo                      # Ctrl+Z = Undo للسطر الحالي

# 5. الـ Aliases (منظمة حسب النوع)
# --- النظام ---
alias ؤمس='clear'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias update='sudo apt update && sudo apt upgrade -y'
alias clean='sudo apt autoremove -y && sudo apt autoclean'
alias sai='sudo apt install'
alias rm='trash-put'
alias reload='source ~/.zshrc'
alias v='nvim'
alias vf='fzf | xargs -r nvim'
alias nsch='nvim $(fzf --preview="batcat --color=always {}")'
alias zsch='zed $(fzf --preview="batcat --color=always {}")'
alias copy='xsel --input --clipboard'
alias paste='xsel --output --clipboard'
# --- الأدوات البديلة (Modern Tools) ---
alias ls='eza --icons --color=always --group-directories-first'
alias ll='eza -alh --icons --color=always --group-directories-first --git'
alias la='eza -a --icons --color=always'
alias tree='eza -T'
alias cat='batcat --paging=never'
alias bat='batcat'
alias fd='fdfind'
alias jl='jupyter-lab'

# --- البرمجة (Python, Django, C++) ---
alias python=python3.12
alias py=python3.12
alias act='source .venv/bin/activate'
alias runserver='python manage.py runserver'
alias urunserver='uv run python manage.py runserver'
alias makemig='python manage.py makemigrations'
alias mig='python manage.py migrate'

alias mkvenv='virtualenv'
alias spsql='sudo systemctl start postgresql'

crun () { g++ -std=c++17 "$1" -o "${1%.cpp}" && "./${1%.cpp}"; }

# 6. الدوال الذكية (Functions)
# مدير الملفات Yazi مع الانتقال للمسار عند الخروج
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# البحث داخل الملفات وفتح نيو فيم
fif() {
  rg --files-with-matches --no-messages "$1" | \
    fzf --preview "rg --ignore-case --pretty --context 10 '$1' {}" | xargs -r nvim
}
# البحث التفاعلي داخل النصوص (Interactive Ripgrep)
frg() {
  local RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case --glob '!.git/'"
  local INITIAL_QUERY="${*:-}"
  
  fzf --ansi --disabled --query "$INITIAL_QUERY" \
      --bind "start:reload:$RG_PREFIX {q}" \
      --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
      --delimiter : \
      --preview 'batcat --color=always --highlight-line {2} --style=numbers {1}' \
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
# 7. إعدادات الـ History
HISTSIZE=10000
SAVEHIST=10000
setopt share_history append_history inc_append_history hist_ignore_dups

# 8. تفعيل الأدوات (مرة واحدة فقط لسرعة التشغيل)
eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"

if command -v thefuck >/dev/null 2>&1; then
    eval "$(thefuck --alias fk)"
fi

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# 9. اللمسات النهائية
export BAT_THEME="Catppuccin Mocha"

# تفعيل إضافة تعديل الأوامر
autoload -U edit-command-line
zle -N edit-command-line

# ربطها باختصار (هنا استخدمنا Alt + e)
bindkey '^[e' edit-command-line

fastfetch
