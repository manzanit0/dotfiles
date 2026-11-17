#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/manzanit0/dotfiles.git"
REPO_DIR="${DOTFILES_DIR:-$HOME/repositories/manzanit0/dotfiles}"
OMZ_DIR="$HOME/.oh-my-zsh"
TPM_DIR="$HOME/.tmux/plugins/tpm"
SSH_KEY="$HOME/.ssh/id_ed25519"
GPG_KEY_ID="108E89384907FB72"
DRY_RUN="${DRY_RUN:-0}"

export GIT_CONFIG_GLOBAL=/dev/null

log() {
  printf '\n==> %s\n' "$*"
}

warn() {
  printf 'warning: %s\n' "$*" >&2
}

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf 'dry-run: %s\n' "$*"
    return 0
  fi
  "$@"
}

require_macos() {
  if [[ "$(uname)" != "Darwin" ]]; then
    echo "This setup only runs on macOS." >&2
    exit 1
  fi
}

brew_bin() {
  if [[ "$(uname -m)" == "arm64" ]]; then
    echo /opt/homebrew/bin/brew
  else
    echo /usr/local/bin/brew
  fi
}

prime_sudo() {
  [[ "$DRY_RUN" == "1" ]] && return 0
  log "Requesting administrator access"
  sudo -v
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
}

ensure_ssh_key() {
  if [[ -f "$SSH_KEY" || -f "$HOME/.ssh/id_rsa" ]]; then
    return 0
  fi
  log "Generating SSH key"
  run mkdir -p "$HOME/.ssh"
  run chmod 700 "$HOME/.ssh"
  run ssh-keygen -t ed25519 -f "$SSH_KEY" -C "$(whoami)@$(hostname -s)"
  run ssh-add --apple-use-keychain "$SSH_KEY"
}

install_homebrew() {
  local brew
  brew="$(brew_bin)"
  if [[ ! -x "$brew" ]]; then
    log "Installing Homebrew"
    local url="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"
    NONINTERACTIVE=1 run /bin/bash -c "$(curl -fsSL "$url")"
  fi
  if [[ -x "$brew" ]]; then
    eval "$("$brew" shellenv)"
    run brew analytics off
  fi
}

resolve_repo() {
  local script_dir=""
  if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  fi
  if [[ -n "$script_dir" && -f "$script_dir/Brewfile" ]]; then
    REPO_DIR="$script_dir"
    return 0
  fi
  if [[ ! -d "$REPO_DIR/.git" ]]; then
    log "Cloning dotfiles into $REPO_DIR"
    run mkdir -p "$(dirname "$REPO_DIR")"
    run git clone "$REPO_URL" "$REPO_DIR"
  fi
}

install_packages() {
  log "Installing Homebrew packages"
  run brew bundle --file "$REPO_DIR/Brewfile"
}

link_file() {
  local src="$1"
  local dest="$2"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    return 0
  fi
  run mkdir -p "$(dirname "$dest")"
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    run mv "$dest" "$dest.backup-$(date +%Y%m%d%H%M%S)"
  fi
  run ln -sfn "$src" "$dest"
  echo "linked ${dest/#$HOME/~}"
}

link_dotfiles() {
  log "Linking dotfiles"
  local root="$REPO_DIR/dotfiles"
  local src
  while IFS= read -r -d '' src; do
    link_file "$src" "$HOME/${src#"$root"/}"
  done < <(find "$root" -type f ! -name .DS_Store -print0)
}

clone_if_missing() {
  local url="$1"
  local dest="$2"
  if [[ ! -d "$dest" ]]; then
    run git clone --depth 1 "$url" "$dest"
  fi
}

install_oh_my_zsh() {
  log "Installing oh-my-zsh"
  if [[ ! -d "$OMZ_DIR" ]]; then
    local url="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes run sh -c "$(curl -fsSL "$url")"
  fi
  clone_if_missing https://github.com/mroth/evalcache \
    "$OMZ_DIR/custom/plugins/evalcache"
}

install_tmux_plugins() {
  log "Installing tmux plugins"
  clone_if_missing https://github.com/tmux-plugins/tpm "$TPM_DIR"
  run "$TPM_DIR/bin/install_plugins" \
    || warn "tmux plugin install failed; press prefix + I inside tmux."
}

configure_shell_profile() {
  local profile="$HOME/.zprofile"
  if grep -qs 'brew shellenv' "$profile"; then
    return 0
  fi
  log "Adding Homebrew to $profile"
  [[ "$DRY_RUN" == "1" ]] && return 0
  printf '\neval "%s(%s shellenv)"\n' "$" "$(brew_bin)" >> "$profile"
}

configure_gpg_agent() {
  local conf="$HOME/.gnupg/gpg-agent.conf"
  if grep -qs 'pinentry-program' "$conf"; then
    return 0
  fi
  log "Configuring gpg-agent pinentry"
  [[ "$DRY_RUN" == "1" ]] && return 0
  mkdir -p "$HOME/.gnupg"
  chmod 700 "$HOME/.gnupg"
  echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" >> "$conf"
}

apply_macos_defaults() {
  log "Applying macOS defaults"
  run defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  run defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
  run defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  run defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
  run defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
  run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  run defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  run defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
  run defaults write com.apple.finder ShowStatusBar -bool true
  run defaults write com.apple.finder ShowPathbar -bool true
  run defaults write com.apple.finder AppleShowAllFiles -bool true
  run defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
  run defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
  run defaults write com.apple.finder WarnOnEmptyTrash -bool false
  run defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  run defaults write com.apple.dock expose-animation-duration -float 0.1
  run defaults write com.apple.dock tilesize -int 56
  run defaults write com.apple.dock show-process-indicators -bool true
  run defaults write com.apple.dock showhidden -bool true
  run defaults write com.apple.dock autohide -bool true
  run defaults write com.apple.dock autohide-delay -float 0
  run chflags nohidden "$HOME/Library"
  run killall Dock Finder || true
}

print_next_steps() {
  local pubkey="$SSH_KEY.pub"
  [[ -f "$pubkey" ]] || pubkey="$HOME/.ssh/id_rsa.pub"
  cat <<EOF

All done. Manual steps left:
  1. Add $pubkey to https://github.com/settings/keys
     (git rewrites GitHub HTTPS URLs to SSH, so nvim plugins need it).
  2. Import GPG key $GPG_KEY_ID; commits are signed with it.
  3. Open a new terminal, then run nvim once to install plugins.
  4. Log out and back in for all macOS defaults to apply.
EOF
}

main() {
  require_macos
  prime_sudo
  ensure_ssh_key
  install_homebrew
  resolve_repo
  install_packages
  install_oh_my_zsh
  install_tmux_plugins
  link_dotfiles
  configure_shell_profile
  configure_gpg_agent
  apply_macos_defaults
  print_next_steps
}

main "$@"
