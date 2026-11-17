# My dotfiles

macOS only. One script sets up a fresh machine:

```
bash -c "$(curl -fsSL https://raw.githubusercontent.com/manzanit0/dotfiles/master/setup.sh)"
```

Or, from a checkout: `./setup.sh`. It is safe to re-run.

## What it does

1. Generates an SSH key if there is none.
2. Installs Homebrew and everything in `Brewfile`.
3. Logs in to GitHub with `gh` (one browser confirmation) and uploads
   the SSH key for both authentication and commit signing.
4. Clones this repo to `~/repositories/manzanit0/dotfiles`
   (override with `DOTFILES_DIR`).
5. Installs oh-my-zsh and its custom plugins.
6. Symlinks every file under `dotfiles/` into `$HOME`, backing up
   whatever was there as `<file>.backup-<timestamp>`.
7. Applies macOS defaults.

`DRY_RUN=1 ./setup.sh` prints the commands without running them.

Afterwards, launch `nvim` once to install plugins.
