# dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

Secrets are encrypted with [age](https://age-encryption.org/) — this repo is safe to be public.

## What's included

| Tool | Config |
|---|---|
| zsh | `.zshrc` |
| git | `.gitconfig` |
| tmux | `.tmux.conf` |
| WezTerm | `.config/wezterm/` |
| Neovim (LazyVim) | `.config/nvim/` |
| Starship | `.config/starship.toml` |
| lazygit | `.config/lazygit/` |
| opencode | `.config/opencode/` |
| skhd | `.config/skhd/` |
| GPG agent | `.gnupg/gpg-agent.conf` |
| SSH keys | `.ssh/` (private key encrypted) |
| Homebrew | `.Brewfile` |

## New machine setup

### 1. Install Homebrew

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 2. Install chezmoi and apply

```sh
brew install chezmoi
chezmoi init git@github.com:tinque/dotfiles.git
```

### 3. Restore the age decryption key

Copy `key.txt` from your Bitwarden vault to:

```
~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt
```

### 4. Apply dotfiles

```sh
chezmoi apply
```

This will deploy all configs and automatically import GPG keys on first run.

### 5. Install Homebrew packages

```sh
brew bundle --global
```

### 6. Post-install

- Open WezTerm — tmux starts automatically
- Open Neovim — Lazy will install all plugins on first launch
- Grant Accessibility permission to `skhd` in System Settings > Privacy & Security
- Install tmux plugins: `prefix + I` (capital i) inside tmux
