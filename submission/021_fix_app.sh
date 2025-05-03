#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/00_init.sh"

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
export PATH="$HOME/.cargo/bin:$PATH"
source ~/.bashrc  # or `source ~/.zshrc` if you're using Zsh
cargo --version
pip install aiohttp-csrf
