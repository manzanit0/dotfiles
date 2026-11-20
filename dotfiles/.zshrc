# Uncomment to profile
# zmodload zsh/zprof

export PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME=robbyrussell

plugins=(evalcache git macos history-substring-search asdf)

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

source $ZSH/oh-my-zsh.sh

# if type asdf &>/dev/null; then
# . $HOME/.asdf/asdf.sh
# fpath=(${ASDF_DIR}/completions $fpath)
# fi

# autoload -Uz compinit && compinit

_evalcache direnv hook zsh

if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
elif type fzf &>/dev/null; then
  source <(fzf --zsh)
fi

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Enabled history for Elixir iex
export ERL_AFLAGS="-kernel shell_history enabled"

# rust stuff
export PATH=$PATH:$HOME/.cargo/bin

# GOPATH :)
# At the moment asdf is taking care of these.
# export GOROOT=$(go env GOROOT)
export GOPATH=$(go env GOPATH)
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Some convenience function
function docker-rm-all-containers {
  docker stop $(docker ps -aq)
  docker rm $(docker ps -aq)
}

function docker-rm-all-images {
  docker-rm-all-containers
  docker rmi -f $(docker images -q)
}

function pg-docker {
  docker run --rm --name pg-docker -e POSTGRES_PASSWORD=docker -d -p 5432:5432 -v $HOME/docker/volumes/postgres:/var/lib/postgresql/data postgres
}

function find-pods {
  kubectl get pods -n $1 -l name=$2
}

function uuid {
  uuidgen | tr '[:upper:]' '[:lower:]'
}

function source-dotnenv {
  set -o allexport
  source .env
  set +o allexport
}

# Invoke elixir help from terminal
# Usage: `exdoc Enum.map`
function exdoc {
  elixir -e "require IEx.Helpers; IEx.Helpers.h($1)"
}

function bw-unlock {
  # Depends on BW_PASSWORD env var being exported in the environment.
  export BW_SESSION=$(bw unlock --passwordenv BW_PASSWORD --raw)
}

function timezsh {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

function fkill {
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]; then
    kill -${1:-9} $pid
  fi
}

path() {
  echo $PATH | tr ':' '\n'
}

alias dict="dict -d wn"

alias /$=''

alias aws-params='open "https://eu-west-1.console.aws.amazon.com/systems-manager/parameters/?region=eu-west-1&tab=Table"'

alias rw="railway"

# Some handy aliases to work with Bitwarden CLI
alias bw-search='bw list items --search'
alias bw-pw-copy="jq -r '.[0].login.password' | pbcopy"
alias bw-generate='bw generate -p --words 4 --separator $'

alias up='docker compose up'
alias down='docker compose down'
alias dp='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"'

alias vim='nvim'

alias ssh-ls='ps aux | grep ssh'

alias ez="$EDITOR ~/.zshrc"
alias sz="source ~/.zshrc"
# Uncomment to profile
# zprof

# OCaml set up
[[ ! -r $HOME/.opam/opam-init/init.zsh ]] || source $HOME/.opam/opam-init/init.zsh >/dev/null 2>/dev/null

alias k="kubectl"
alias d="docker"
alias kn="kubens"
alias aol='function(){aws-okta login "$@"}'
alias ao='function(){aws-okta "$@"}'
alias aox='function(){eval $(aws-okta exec "$@" -- env | grep AWS | sed "s/^/export /");}'

eval "$(starship init zsh)"

# NOTE: this broke at some point??
# . /opt/homebrew/opt/asdf/libexec/asdf.sh
export PATH="/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home/bin:$PATH"

# flutter sdk
export PATH="$PATH:$HOME/development/flutter/bin"

export CDPATH=".:$HOME/repositories/manzanit0"

# SYNOPSIS
#   wf-run [branch]
#
# DESCRIPTION
#   Triggers the "gh workflow run" command to run a GitHub Action.
#   If no branch is provided, it fallsback to the HEAD in the current directory.
function wf-run() {
  REF=$1
  REF=${REF:-$(git rev-parse --abbrev-ref HEAD)}
  echo "Using ref $REF for running the workflow"
  gh workflow run --ref $REF
}

function kn() { k config set-context --current --namespace=$1 }

function ghpr() {
  if [[ -n "$1" ]]; then
    gh pr create --fill --assignee @me --body="$(git log origin..HEAD --format="*%s%n%b")" --draft --title $1
  else
    gh pr create --fill --assignee @me --body="$(git log origin..HEAD --format="*%s%n%b")" --draft
  fi

  gh pr view --web
}

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

SSH_ENV="$HOME/.ssh/agent-environment"

function start_agent {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add;
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
    . "${SSH_ENV}" > /dev/null
    #ps ${SSH_AGENT_PID} doesn't work under cywgin
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_agent;
    }
else
    start_agent;
fi

export PATH="$HOME/.deno/bin:$PATH"

export MANPAGER="nvim +Man\!"

function settf() {
  version="$1"
  arch="${2:-$(/usr/bin/arch)}"
  mkdir -p "${HOME}/terraform"
  if [[ ! -f "${HOME}/terraform/${version}" ]]; then
    url="https://releases.hashicorp.com/terraform/${version}/terraform_${version}_darwin_${arch}.zip"
    if ! curl --head --silent --fail "$url" > /dev/null 2>&1; then
      echo "'${version}' does not appear to be a valid terraform version"
      return 1
    fi
    echo "Downloading terraform ${version} (${url})..."
    curl -sS "$url" -o /tmp/terraform.zip
    unzip -p /tmp/terraform.zip terraform > "${HOME}/terraform/${version}"
    chmod +x "${HOME}/terraform/${version}"
  fi
  ln -s -f "${HOME}/terraform/${version}" /usr/local/bin/terraform
  echo "Now using terraform ${version}"
}
complete -F _tf settf


function k-az-from-pod() {
kubectl get pod $1 -o jsonpath='{.spec.nodeName}' | xargs kubectl get node -o jsonpath='{.metadata.labels.topology\.kubernetes\.io/zone}'
}

alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

alias vyq="nvim -c 'set ft=yaml' -"

