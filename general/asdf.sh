#!/usr/bin/env bash

git clone https://github.com/asdf-vm/asdf.git ~/.asdf
cd ~/.asdf
git checkout "$(git describe --abbrev=0 --tags)"

# I use zsh, but make it work in bash too for the odd day
echo ". $HOME/.asdf/asdf.sh" > ~/.bashrc
echo ". $HOME/.asdf/completions/asdf.bash" > ~/.bashrc

# Elixir/Erlang/OTP
# Some necessary libs for Erlang
brew install autoconf
export KERL_CONFIGURE_OPTIONS="--without-javac --with-ssl=$(brew --prefix openssl)"

asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf install erlang 23.0.2
asdf global erlang 23.0.2

asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf install elixir 1.10.3-otp-23
asdf global elixir 1.10.3-otp-23

# NodeJS
brew install coreutils
brew install gpg

asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git

bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring

asdf install nodejs 14.4.0
asdf global nodejs 14.4.0
