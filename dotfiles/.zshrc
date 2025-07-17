# Uncomment to profile
# zmodload zsh/zprof

export PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME=robbyrussell

plugins=(evalcache git macos tmux github fasd history-substring-search asdf)

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

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

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

# PHP
export PATH="$PATH:$HOME/.composer/vendor/bin"

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

function pg-stop {
  sudo /etc/init.d/postgresql stop
}

function pg-start {
  sudo /etc/init.d/postgresql start
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

function mfa-code {
  local paster
  if [ -z "$(command -v gauth)" ]; then
    echo "gauth is not available run: go get github.com/pcarrier/gauth" >&2
    return 1
  fi
  paster=cat
  # case "$(uname -s)" in
  # 	([Dd]arwin*) paster="pbcopy"  ;;
  # 	([Ll]inux*) paster="xclip -i"  ;;
  # esac
  gauth | grep -i "$1" | awk '{print $(NF-1)}' | $paster
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
alias httpry="httpry -f timestamp,dest-ip,direction,method,status-code,host,request-uri"

alias /$=''

alias aws-params='open "https://eu-west-1.console.aws.amazon.com/systems-manager/parameters/?region=eu-west-1&tab=Table"'

alias rw="railway"

# Allow tmux work properly (hack?)
# alias tmux="TERM=screen-256color-bce tmux"
# set -g default-terminal "screen-256color"
#
alias update-nvim-stable='asdf uninstall neovim stable && asdf install neovim stable'
alias update-nvim-nightly='asdf uninstall neovim nightly && asdf install neovim nightly'
alias update-nvim-master='asdf uninstall neovim ref:master && asdf install neovim ref:master'

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
[[ ! -r /Users/manzanit0/.opam/opam-init/init.zsh ]] || source /Users/manzanit0/.opam/opam-init/init.zsh >/dev/null 2>/dev/null

alias k="kubectl"
alias d="docker"
alias kn="kubens"
alias aol='function(){aws-okta login "$@"}'
alias ao='function(){aws-okta "$@"}'
alias aox='function(){eval $(aws-okta exec "$@" -- env | grep AWS | sed "s/^/export /");}'
alias eks='infra-cli aws configEks'

eval "$(starship init zsh)"

# NOTE: this broke at some point??
# . /opt/homebrew/opt/asdf/libexec/asdf.sh
export PATH="/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home/bin:$PATH"

# flutter sdk
export PATH="$PATH:/Users/manzanit0/development/flutter/bin"

export CDPATH=".:/Users/manzanit0/repositories/docker:/Users/manzanit0/repositories/manzanit0"

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

function wk-bash {
  case $1 in
  help)
    echo "
SYNOPSIS
  wk [command] [args...]

DESCRIPTION
  Useful commands for daily workflow.

  COMMAND: wk gh pr pending
    opens PRs pending review.

  COMMAND: wk gh pr open
    Open PR for pushed branch and open it in the browser

  COMMAND: wk gh run [branch]
    Triggers the "gh workflow run" command to run a GitHub Action.
    If no branch is provided, it fallsback to the HEAD in the current directory.

  COMMAND wk grafana [env] [service]
    opens Docker Telemetry dash in grafana for provided service.
    if no environment is provided, production is assumed.
    example: wk grafana garant"
    ;;
  gh)
    if [ $2 = "pr" ] && [ $3 = "open" ]; then
      gh pr create --fill --draft
      gh pr view --web
    elif [ $2 = "pr" ] && [ $3 = "pending" ]; then
      open "https://github.com/pulls?q=is%3Aopen+is%3Apr+archived%3Afalse+user%3Adocker+review-requested%3AManzanit0+draft%3Afalse"
    elif [$2 = "run" ]; then
      REF=$3
      REF=${REF:-$(git rev-parse --abbrev-ref HEAD)}
      echo "Using ref $REF for running the workflow"
      gh workflow run --ref $REF
    fi
    ;;

  grafana)
    HOST="grafana.proxy.us-east-1.aws.dckr.io"
    if [ $2 = "stage" ]; then
      HOST="grafana.proxy.stage-us-east-1.aws.dckr.io"
      SERVICE_NAME=$3
    elif [ $2 = "production" ]; then
      SERVICE_NAME=$3
    else
      SERVICE_NAME=$2
    fi

    open "https://$HOST/d/Bw7j1zsjk/docker-telemetry?var-service=$SERVICE_NAME&var-Datasource=cortex&var-interval=1m"
    ;;
  *)
    echo "unknown command"
    ;;
  esac
}

function ll {
  cd "$(llama "$@")"
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

function ghwf() {
    if [ $1 = "promote" ]; then
      service_name=$2
      gh workflow run promote-production.yaml --repo docker/hub-platform-services -f app_path="cloud-platform/$service_name.yaml";
    elif [ $1 = "see-promotion" ]; then
      workflow_id=$(gh run list \
          --workflow=promote-production.yaml \
          --repo docker/hub-platform-services \
          --json conclusion,number,databaseId,createdAt \
          --created 2024-06-12 | jq --raw-output 'sort_by(.number) | first | .databaseId')

      gh run view "$workflow_id" \
          --repo docker/hub-platform-services \
          --json headBranch,jobs,name,number,status,url,conclusion | jq --raw-output
    fi
}

# bun completions
[ -s "/Users/manzanit0/.bun/_bun" ] && source "/Users/manzanit0/.bun/_bun"

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

export PATH="/Users/manzanit0/.deno/bin:$PATH"

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

alias claude="/Users/manzanit0/.claude/local/claude"
