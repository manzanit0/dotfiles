# My dotfiles

macOS only. One script sets up a fresh machine:

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/manzanit0/dotfiles/master/setup.sh)"
```

Or, from a checkout: `./setup.sh`. It is safe to re-run.

## What it does

1. Generates an SSH key if there is none.
2. Installs Homebrew and everything in `Brewfile`.
3. Clones this repo to `~/repositories/manzanit0/dotfiles`
   (override with `DOTFILES_DIR`).
4. Installs oh-my-zsh and its custom plugins.
5. Symlinks every file under `dotfiles/` into `$HOME`, backing up
   whatever was there as `<file>.backup-<timestamp>`.
6. Applies macOS defaults.

`DRY_RUN=1 ./setup.sh` prints the commands without running them.

## Manual steps afterwards

- Add the SSH public key to GitHub.
- Import the GPG signing key.
- Launch `nvim` once to install plugins.
