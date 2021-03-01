#!/usr/bin/env bash

wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

. ~/.nvm/nvm.sh
. ~/.profile
. ~/.bashrc

command -v nvm

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

NVM_VERSION=10.14.2
nvm install $NVM_VERSION

# install pm2
npm install -g pm2

ln -s /var/www/site/DockerLocal/ecosystem.config.js /var/www/
