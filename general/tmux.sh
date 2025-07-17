#!/usr/bin/env bash -xe

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "source ~/repositories/manzanit0/dotfiles/dotfiles/.tmux.conf" > ~/.tmux.conf

if [[ "$(uname)" == "Linux" ]]; then
    apt install -y tmux
    apt install fonts-powerline
fi

# On MacOS you have to config iterm to use the font
if [[ "$(uname)" == "Darwin" ]]; then
    git clone https://github.com/powerline/fonts.git --depth=1
    cd fonts
    ./install.sh
    cd ..
    rm -rf fonts
fi

# TODO Remember to then install all tmux plugins it with ctrl + b + I
