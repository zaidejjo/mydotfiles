# Zaid Ajo's ZSH CONFIG
# zmodload zsh/zprof

# تمنع هذه القيمة Oh My Zsh أو الإضافات الأخرى من إجبار compinit على العمل مجدداً
ZSH_DISABLE_COMPFIX="true"

[[ -o interactive ]] || return
fpath=(/usr/share/zsh/site-functions $fpath)
fpath=(~/.zsh/completion $fpath)

# 1. إجبار Oh My Zsh على فحص التحديثات في الخلفية دون تعطيل الطرفية
# zstyle ':omz:update' mode background
DISABLE_AUTO_UPDATE="true"

# 2. إخبار Oh My Zsh أننا قمنا بإعداد compinit بأنفسنا ولا نريده أن يعيد تشغيلها
# (هذا السطر السحري يمنع التكرار ويجعل oh-my-zsh يتخطى مرحلة الـ compinit الخاصة به)
ZSH_AUTOLOAD_COMPINIT="no"

# تسريع نظام الإكمالات كلياً ومنع التكرار
autoload -Uz compinit
define_compile_compinit() {
  local zcdump="${ZDOTDIR:-$HOME}/.zcompdump"
  if [[ -f "$zcdump" && -n "$zcdump"(#qN.m-1) ]]; then
    compinit -C -u
  else
    compinit -u
    # تحويل الملف إلى صيغة ثنائية سريعة القراءة للمعالج
    zrecompile "$zcdump"
  fi
}
define_compile_compinit

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
export PATH="$HOME/.local/bin:/opt/cmake/bin:$HOME/.npm-global/bin:$PATH"
if [ -d "/home/linuxbrew/.linuxbrew" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
[ -f ~/.pypi_secrets ] && source ~/.pypi_secrets

[ -f ~/.secrets ] && source ~/.secrets

export EDITOR='nvim'
alias snvim="sudoedit"
export VISUAL='nvim'
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
export TERMINAL="wezterm"

export ZSH="$HOME/.oh-my-zsh"
plugins=(git sudo archlinux uv fzf-tab zsh-autosuggestions zsh-syntax-highlighting history-substring-search)
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
--layout=reverse --height=70% --border='rounded' --margin=1,2 --padding=1 \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=border:#585b70,label:#fab387 \
--border-label='  Search ' --border-label-pos=2 \
--prompt='  ' --pointer=' ' --marker=' ' "
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
alias ؤمس='clear'
alias cls='clear'
alias cl='clear'
alias ؤي='cd'
alias ..='cd ..'
alias .3='cd ../..'
alias .4='cd ../../..'
alias .5='cd ../../../..'
alias update='sudo pacman -Syu'
alias clean='sudo apt autoremove -y && sudo apt autoclean'
alias ins='sudo pacman -S'
alias rm='trash-put'
alias reload='source ~/.zshrc'
alias v='nvim'
alias nano='nvim'
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
alias lg='lazygit'

# --- UV & Python Optimized ---
alias pip='uv pip'
alias venv='uv venv'
alias py='uv run python'
alias uinst='uv add'
alias urm='uv remove'
alias dj='uv run manage.py'
alias drun='uv run manage.py runserver 0.0.0.0:8000'
alias dmm='uv run manage.py makemigrations'
alias dms='uv run manage.py migrate_schemas'
alias dmig='uv run manage.py migrate'
alias dsh='uv run manage.py shell'
alias dbsh='uv run manage.py dbshell'
alias dsu='uv run manage.py createsuperuser'
alias dcolstc='uv run manage.py collectstatic'
alias dcheck='uv run manage.py check'
# --- البرمجة (Python, Django, C++) ---

alias runserver='python manage.py runserver'

alias spsql='sudo systemctl start postgresql'


# Docs
alias mergeall='mkdir -p temp_pdf && libreoffice --headless --convert-to pdf *.* --outdir temp_pdf && gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=Merged_Files_$(date +%Y%m%d_%H%M%S).pdf temp_pdf/*.pdf && rm -rf temp_pdf'

# Nuxt and Bun dev
alias bd='bun run dev'
alias bbuild='bun run build'
alias build-desktop="TAURI_BUILD=true bun --cwd frontend run generate && bun --cwd desktop run tauri build"

alias wifi='wlctl'
# Music & mpv
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

# 3. إجبار fzf-tab و zsh على تجاهل الملفات تماماً لـ dj
# هذا السطر يخبر النظام: عند إكمال dj، استخدم وظيفة الإكمال فقط ولا تحاول تخمين ملفات
zstyle ':completion:*:*:dj:*' file-patterns ''
zstyle ':completion:*:*:dj:*' menu yes select

# 4. ربط الوظيفة
compdef _django_custom_completion dj
crun () { g++ -std=c++17 "$1" -o "${1%.cpp}" && "./${1%.cpp}"; }

alias ytdl='yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4'
alias yt-up='sudo yt-dlp -U'
alias yt-playlist='yt-dlp -i -x --audio-format mp3 --yes-playlist'
alias ytmp3='yt-dlp -x --audio-format mp3 --audio-quality 0 -o "%(title)s.%(ext)s"'
alias vpn-on="sudo openvpn --config /home/zaid/nl-free-104.protonvpn.udp.ovpn --daemon"
alias vpn-off="sudo killall openvpn"
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)" }
# cx() { cd "$@" && ll; }
cx() {
    local show_hidden=0
    local target_dir="."

    # قراءة الخيارات الممررة للدالة
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a) show_hidden=1; shift ;;
            -*) shift ;; # تجاهل الخيارات الأخرى مثل l أو h لأن الجدول منسق تلقائياً
            *) target_dir="$1"; shift ;;
        esac
    done

    # الانتقال للمجلد إذا تم تحديده
    if [ -d "$target_dir" ]; then
        local original_dir="$PWD"
        cd "$target_dir" || return
    fi

    # رأس الجدول (Header)
    echo -e "\e[1;36m┌─────┬────────────────────────────────┬──────────┬──────────────────┐\e[0m"
    echo -e "\e[1;36m│ \e[1;33m#   \e[1;36m│ \e[1;33mName                           \e[1;36m│ \e[1;33mType     \e[1;36m│ \e[1;33mModified         \e[1;36m│\e[0m"
    echo -e "\e[1;36m├─────┼────────────────────────────────┼──────────┼──────────────────┤\e[0m"

    local i=1

    # جلب المجلدات أولاً ثم الملفات بناءً على خيار إظهار المخفي
    if [ "$show_hidden" -eq 1 ]; then
        (
            find . -maxdepth 1 -mindepth 1 -type d ! -name '.' ! -name '..' | sort
            find . -maxdepth 1 -mindepth 1 -type f | sort
        )
    else
        (
            find . -maxdepth 1 -mindepth 1 -type d ! -name '.*' | sort
            find . -maxdepth 1 -mindepth 1 -type f ! -name '.*' | sort
        )
    fi |
    while read -r entry; do
        
        # استخراج الاسم فقط بدون المسار ./
        local name="${entry#./}"
        [ -z "$name" ] && continue

        # جلب وقت التعديل الفعلي بشكل موحد
        local mod_time=""
        if [ -d "$name" ] || [ -f "$name" ]; then
            mod_time=$(date -r "$name" "+%d %b %H:%M" 2>/dev/null)
            [ -z "$mod_time" ] && mod_time=$(stat -c '%y' "$name" 2>/dev/null | cut -c1-16)
        fi
        [ -z "$mod_time" ] && mod_time="---"

        # تحديد النوع واللون
        local type_str="File"
        local is_dir=0
        if [ -d "$name" ]; then
            type_str="Dir"
            is_dir=1
        fi

        # تمرير البيانات لـ awk للطباعة المنسقة
        awk -v idx="$i" -v name="$name" -v is_dir="$is_dir" -v type="$type_str" -v mtime="$mod_time" '
        BEGIN {
            color = (is_dir == 1) ? "\033[1;34m" : "\033[0;32m";
            reset = "\033[0m";
            cyan  = "\033[1;36m";
            printf "%s│%s %-3s %s│%s %s%-30s%s %s│%s %-8s %s│%s %-16s %s│%s\n", \
                   cyan, reset, idx, cyan, reset, color, name, reset, cyan, reset, type, cyan, reset, mtime, cyan, reset
        }'
        
        i=$((i+1))
    done

    # نهاية الجدول (Footer)
    echo -e "\e[1;36m└─────┴────────────────────────────────┴──────────┴──────────────────┘\e[0m"

    # الرجوع للمجلد الأصلي إذا كنا قد غيرناه لعرض المحتويات فقط
    if [ -n "$original_dir" ]; then
        cd "$original_dir" || return
    fi
}
ce() {
    # الانتقال للمجلد إذا تم تمريره كـ Argument
    [ -n "$1" ] && cd "$1"

    echo -e "\e[1;36m┌──────────────────────────────────────────────────────────┐\e[0m"
    echo -e "\e[1;36m│\e[1;33m   Contents of: \e[1;35m$PWD \e[1;36m\e[0m"
    echo -e "\e[1;36m└──────────────────────────────────────────────────────────┘\e[0m"

    # استخدام eza لعرض جدول احترافي ملون بالأيقونات وتفاصيل الـ Git
    eza --long --grid --icons --color=always --group-directories-first --git --time-style=relative
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
mkcd() {
  mkdir -p "$1" && cd "$1"
}

histsize=10000
savehist=10000
setopt share_history append_history inc_append_history hist_ignore_dups


if command -v thefuck >/dev/null 2>&1; then
    eval "$(thefuck --alias fk)"
fi
# export PYENV_ROOT="$HOME/.pyenv"
# [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

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
bindkey '^e' autosuggest-accept  # اضغط Ctrl + E لقبول الاقتراح الرمادي فوراً


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
# eval "$(uv generate-shell-completion zsh)"

alias taalomi='dj school_portal'
export PATH="$HOME/bin:$PATH"


djd() {
    local cmd
    # قائمة الأوامر التي تريدها
    cmd=$(echo "runserver\nmakemigrations\nmigrate\nshell\ndbshell\ncollectstatic\ncreatesuperuser" | fzf --height 40% --reverse --header "Select Django Command")
    
    if [ -n "$cmd" ]; then
        # تنفيذ الأمر باستخدام uv
        uv run manage.py $cmd
    fi
}

if [[ $- == *i* ]] && [ -z "$ZELLIJ" ]; then
  if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
    command -v zellij >/dev/null 2>&1 && \
      (zellij attach main || zellij -s main)
  fi
fi
setxkbmap -option ctrl:nocaps


fastfetch
DISABLE_AUTO_TITLE="false"
alias ask='tgpt'

# pnpm
export PNPM_HOME="/home/zaid/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
alias gcm='git switch main'
alias gcd='git switch dev'
alias gw='git switch'
alias gcrag='git switch feature/faiss-rag'

alias odysseus="tmux new-session -d -s odysseus 'cd /home/zaid/odysseus && source venv/bin/activate && python -m uvicorn app:app --host 127.0.0.1 --port 7000'"
alias odysseus-stop="tmux kill-session -t odysseus"

export ANDROID_HOME=/opt/android-sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/tools/bin"

export NVM_DIR="$HOME/.config/nvm"

# دالة لتحميل NVM الحقيقي عند أول استخدام
_load_nvm() {
    unset -f nvm node npm npx yarn
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

# إنشاء اختصارات وهمية مؤقتة
nvm() { _load_nvm; nvm "$@"; }
node() { _load_nvm; node "$@"; }
npm() { _load_nvm; npm "$@"; }
npx() { _load_nvm; npx "$@"; }
yarn() { _load_nvm; yarn "$@"; }

export OPENCODE_EXPERIMENTAL_CACHE_STABILIZATION=1
export OPENCODE_CACHE_AUDIT=1
export OPENCODE_EXPERIMENTAL_CACHE_1H_TTL=1

# Added by Antigravity CLI installer
export PATH="/home/zaid/.local/bin:$PATH"

alias apt='sudo nala'

# pnpm env variables
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# zprof

# bun completions
[ -s "/home/zaid/.bun/_bun" ] && source "/home/zaid/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
alias bnmodule='bunx nuxi@latest module add'
alias pnmodule='pnx nuxi@latest module add'

export PATH=/home/zaid/bin:$PATH

[[ -e "/home/zaid/lib/oracle-cli/lib/python3.14/site-packages/oci_cli/bin/oci_autocomplete.sh" ]] && source "/home/zaid/lib/oracle-cli/lib/python3.14/site-packages/oci_cli/bin/oci_autocomplete.sh"
export PATH_NPM="$(npm config get prefix)/bin"
export PATH="$PATH:$PATH_NPM"
export PATH="$PATH:$HOME/flutter/bin"  # ✅ PATH كبير، HOME كبير
export ANDROID_HOME=$HOME/Android/Sdk  # ✅ ANDROID_HOME كبير
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export CHROME_EXECUTABLE=/usr/bin/brave
