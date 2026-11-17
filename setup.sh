#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/manzanit0/dotfiles.git"
REPO_DIR="${DOTFILES_DIR:-$HOME/repositories/manzanit0/dotfiles}"
OMZ_DIR="$HOME/.oh-my-zsh"
SSH_KEY="$HOME/.ssh/id_ed25519_github"
GITHUB_KEY_SCOPES="admin:public_key,admin:ssh_signing_key"
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
  if [[ -f "$SSH_KEY" ]]; then
    return 0
  fi
  log "Generating SSH key"
  run mkdir -p "$HOME/.ssh"
  run chmod 700 "$HOME/.ssh"
  run ssh-keygen -t ed25519 -f "$SSH_KEY" -C "$(whoami)@$(hostname -s)"
  run ssh-add --apple-use-keychain "$SSH_KEY"
}

configure_ssh_for_github() {
  local conf="$HOME/.ssh/config"
  if grep -qs '^Host github.com$' "$conf"; then
    return 0
  fi
  log "Pointing SSH at $SSH_KEY for github.com"
  [[ "$DRY_RUN" == "1" ]] && return 0
  mkdir -p "$HOME/.ssh"
  printf '\nHost github.com\n  AddKeysToAgent yes\n  UseKeychain yes\n' >> "$conf"
  printf '  IdentityFile %s\n' "$SSH_KEY" >> "$conf"
  chmod 600 "$conf"
}

github_can_manage_keys() {
  gh api user/keys >/dev/null 2>&1 \
    && gh api user/ssh_signing_keys >/dev/null 2>&1
}

authenticate_github() {
  if github_can_manage_keys; then
    return 0
  fi
  log "Authenticating with GitHub"
  if gh auth token --hostname github.com >/dev/null 2>&1; then
    run gh auth refresh --hostname github.com --scopes "$GITHUB_KEY_SCOPES"
  else
    run gh auth login --hostname github.com --git-protocol ssh --web \
      --skip-ssh-key --scopes "$GITHUB_KEY_SCOPES"
  fi
}

upload_ssh_key_as() {
  local type="$1"
  local endpoint="$2"
  local key_body
  key_body="$(awk '{print $2}' "$SSH_KEY.pub" 2>/dev/null || true)"
  if [[ -n "$key_body" ]] \
    && gh api "$endpoint" --jq '.[].key' 2>/dev/null | grep -qF "$key_body"; then
    return 0
  fi
  run gh ssh-key add "$SSH_KEY.pub" --type "$type" --title "$(hostname -s)" \
    || warn "could not upload the $type key; run gh ssh-key add manually."
}

upload_ssh_key() {
  log "Uploading SSH key to GitHub"
  authenticate_github || warn "GitHub authentication failed."
  upload_ssh_key_as authentication user/keys
  upload_ssh_key_as signing user/ssh_signing_keys
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
  run brew bundle --file "$REPO_DIR/Brewfile" \
    || warn "some packages failed to install; re-run brew bundle."
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

configure_shell_profile() {
  local profile="$HOME/.zprofile"
  if grep -qs 'brew shellenv' "$profile"; then
    return 0
  fi
  log "Adding Homebrew to $profile"
  [[ "$DRY_RUN" == "1" ]] && return 0
  printf '\neval "%s(%s shellenv)"\n' "$" "$(brew_bin)" >> "$profile"
}

configure_rectangle() {
  local src="$REPO_DIR/rectangle/RectangleConfig.json"
  local dest="$HOME/Library/Application Support/Rectangle"
  log "Staging Rectangle config for its next launch"
  run mkdir -p "$dest"
  run cp "$src" "$dest/RectangleConfig.json"
}

apply_macos_defaults() {
  log "Applying macOS defaults"
  run defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
  run defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  run defaults write NSGlobalDomain KeyRepeat -int 2
  run defaults write NSGlobalDomain InitialKeyRepeat -int 15
  run defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
  run defaults write com.apple.dock autohide -bool true
  run defaults write com.apple.dock tilesize -int 88
  run killall Dock Finder || true
}

print_next_steps() {
  printf '\nAll done. Manual steps left:\n'
  echo "  1. Open a new terminal, then run nvim once to install plugins."
  echo "  2. Log out and back in for all macOS defaults to apply."
}

main() {
  require_macos
  prime_sudo
  ensure_ssh_key
  configure_ssh_for_github
  install_homebrew
  resolve_repo
  install_packages
  upload_ssh_key
  install_oh_my_zsh
  link_dotfiles
  configure_shell_profile
  configure_rectangle
  apply_macos_defaults
  print_next_steps
}

main "$@"
