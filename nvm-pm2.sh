#!/usr/bin/env bash

DEFAULT_NVM_VERSION=16.14.2
NVM_VERSION=$DEFAULT_NVM_VERSION;

# Check if file exists /var/www/site/DockerLocal/versions/nvm-version
if [ -f "/var/www/site/DockerLocal/versions/nvm-version" ]; then
    NVM_VERSION=$(</var/www/site/DockerLocal/versions/nvm-version)
fi

# Check if override file exists /var/www/site/DockerLocal/versions/override-nvm-version
if [ -f "/var/www/site/DockerLocal/versions/override-nvm-version" ]; then
    NVM_VERSION=$(</var/www/site/DockerLocal/versions/override-nvm-version)
fi

## See if nvm command exists
## If not, install it
source /var/www/.bashrc

if [ ! -d "/var/www/.nvm" ]; then
    echo "ℹ️ nvm could not be found"
    echo "ℹ️ nvm version $NVM_VERSION will be installed. Override in DockerLocal/versions/override-nvm-version."
    echo "⏳ Installing nvm"
    wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash

    . /var/www/.nvm/nvm.sh
    . /var/www/.bashrc

    command -v nvm

    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    nvm install $NVM_VERSION

    # Install pm2
    echo "⏳ Installing pm2"
    npm install -g pm2

    # Source profile
    echo "⏳ Sourcing profile: /var/www/.bashrc"
    source /var/www/.bashrc
else
    echo "✅ nvm already installed"
fi

# Check if ecosystem.config.js has been setup / needs to be setup
if [ ! -f  "/var/www/ecosystem.config.js" ] &&  [ -f "/var/www/site/DockerLocal/ecosystem.config.js" ]; then
    echo "ecosystem.config.js exists - going to copy it and start pm2"

    # copy ecosystem.config.js
    ln -s /var/www/site/DockerLocal/ecosystem.config.js /var/www/

    # start pm2
    pm2 start
elif [ -f  "/var/www/ecosystem.config.js" ]; then
    echo "🔄 ecosystem.config.js exists - going to restart pm2"

    # restart pm2
    pm2 restart all
fi
