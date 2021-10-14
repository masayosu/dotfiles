: ${OS:=linux}

case "$OSTYPE" in
  darwin*)
    OS=darwin
    ;;
  freebsd*)
    OS=freebsd
    ;;
  windows*)
    OS=windows
    ;;
esac

setopt prompt_subst
setopt no_beep
setopt print_eight_bit
setopt share_history
setopt extended_glob
setopt auto_pushd
setopt pushd_ignore_dups
setopt auto_cd
setopt extended_history
setopt hist_ignore_all_dups
setopt hist_save_nodups
setopt hist_reduce_blanks


export LANG=ja_JP.UTF-8
export EDITOR=vi
# OSXでbrewインストールしてもopensslのリンクが作成されなくなったのでPATH追加
export PATH=/usr/local/opt/openssl/bin:${PATH} && \

# goenv
export PATH="${HOME}/.goenv/bin:${PATH}"
eval "$(goenv init -)"

#rbenv
[[ -d ~/.rbenv  ]] && \
export PATH=${HOME}/.rbenv/bin:${PATH} && \
eval "$(rbenv init -)"

# pyenv
export PYENV_ROOT=${HOME}/.pyenv
if [ -d "${PYENV_ROOT}" ]; then
    export PATH=${PYENV_ROOT}/bin:$PATH
    eval "$(pyenv init -)"
fi

# plenv 
export PLENV_ROOT=${HOME}/.plenv
if [ -d "${PLENV_ROOT}" ]; then
    export PATH=${PLENV_ROOT}/bin:$PATH
    eval "$(plenv init -)"
fi

# direnv
eval "$(direnv hook zsh)"

# Go Path
export GOPATH=$HOME
export PATH=$PATH:$GOPATH/bin

## nvm
#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

# nodenv
[[ -d ~/.nodenv ]] && \
export PATH=${HOME}/.nodenv/bin:${PATH} && \
eval "$(nodenv init -)"

# krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# 色を使用出来るようにする
autoload -Uz colors
colors

# ヒストリの設定
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

# プロンプト
# 1行表示
# PROMPT="%~ %# "
# 2行表示
PROMPT="%{${fg[yellow]}%}[%*] %{${fg[green]}%}%n %{${fg[blue]}%}%c %{${reset_color}%}%# " 

# 右プロンプト
# gitのブランチを表示
autoload -Uz vcs_info
zstyle ':vcs_info:*' actionformats \
    '%F{4}(%f%s%F{4})%F{3}-%F{4}[%F{2}%b%F{3}|%F{1}%a%F{4}]%f '
zstyle ':vcs_info:*' formats       \
    '%F{4}(%f%s%F{4})%F{3}-%F{4}[%F{2}%b%F{4}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'

zstyle ':vcs_info:*' enable git cvs svn

# or use pre_cmd, see man zshcontrib
vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
  fi
}
RPROMPT=$'$(vcs_info_wrapper)'

# 単語の区切り文字を指定する
autoload -Uz select-word-style
select-word-style default
# ここで指定した文字は単語区切りとみなされる
# / も区切りと扱うので、^W でディレクトリ１つ分を削除できる
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

# <Tab> でパス名の補完候補を表示したあと、
# 続けて <Tab> を押すと候補からパス名を選択できるようになる
# 候補を選ぶには <Tab> か Ctrl-N,B,F,P
zstyle ':completion:*:default' menu select=1

# ↑を設定すると、 .. とだけ入力したら1つ上のディレクトリに移動できるので……
# 2つ上、3つ上にも移動できるようにする
alias ...='cd ../..'
alias ....='cd ../../..'
alias vi=vim
alias rm=rmtrash
alias ssh='cat ~/.ssh/config.d/* > ~/.ssh/config; ssh'
alias k=kubectl
alias kx='kubectl ctx'

# diffの結果を色付け
if [[ -x `which colordiff` ]]; then
      alias diff='colordiff -u'
fi
# lsの結果を色付け
case "$OS" in
  freebsd|darwin)
    alias ls="ls -G -w"
    ;;
  linux)
    alias ls="ls --color=auto"
    alias pbcopy="xsel --clipboard --input"
    alias open="xdg-open"
    ;;
esac

# 自動補完を有効にする
# コマンドの引数やパス名を途中まで入力して <Tab> を押すといい感じに補完してくれる
# 例： `cd path/to/<Tab>`, `ls -<Tab>`
autoload -U compinit; compinit

# Emacs ライクな操作を有効にする（文字入力中に Ctrl-F,B でカーソル移動など）
# Vi ライクな操作が好みであれば `bindkey -v` とする
bindkey -e

function select-history() {
  BUFFER=$(history -n -r 1 | fzf --no-sort +m --query "$LBUFFER" --prompt="History > ")
  CURSOR=$#BUFFER
}
zle -N select-history
bindkey '^r' select-history

function ghq-fzf() {
  local src=$(ghq list | fzf --preview "ls -laTp $(ghq root)/{} | tail -n+4 | awk '{print \$9\"/\"\$6\"/\"\$7 \" \" \$10}'")
  if [ -n "$src" ]; then
    BUFFER="cd $(ghq root)/$src"
    zle accept-line
  fi
  zle -R -c
}
zle -N ghq-fzf
bindkey '^T' ghq-fzf


function ssh() {
  # tmux起動時
  if [[ -n $(printenv TMUX) ]] ; then
      # 現在のペインIDを記録
      local pane_id=$(tmux display -p '#{pane_id}')
      # 接続先ホスト名に応じて背景色を切り替え
      if [[ `echo $1 | grep 'prd'` ]] ; then
          tmux select-pane -P 'bg=colour52,fg=white'
      elif [[ `echo $1 | grep 'stg'` ]] ; then
          tmux select-pane -P 'bg=colour25,fg=white'
      fi

      # 通常通りssh続行
      command ssh $@

      # デフォルトの背景色に戻す
      tmux select-pane -t $pane_id -P 'default'
  else
      command ssh $@
  fi
}

export HOMEBREW_NO_AUTO_UPDATE=1
export PATH="/usr/local/opt/curl/bin:$PATH"

[ -f ~/.zshrc.local ] && source ~/.zshrc.local
export PATH="/usr/local/opt/mysql-client/bin:$PATH"
