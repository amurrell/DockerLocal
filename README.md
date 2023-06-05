# DockerLocal

**DockerLocal** is used for setting up a LEMP site to be served on localhost:PORT

**DockerLocal** runs on docker containers - nginx + php-fpm, memcached, redis, mysql/mariadb and your project's web application files. Provides customization for configuring the Dockerfile, nginx, php-fpm, and managing databases.

> **Note:** Your DockerLocal containers can also be used with [ProxyLocal](https://github.com/amurrell/ProxyLocal) for a local DNS of all your DockerLocal projects so that you can run your sites locally at custom domains, like docker.yoursite.com and docker.anothersite.com

---

**Easy Version Setting**

The master branch has the latest versions (see defaults below) - but they are [configurable in the `/versions/` folder](#version-overrides).

You can configure the following:

- Ubuntu Version (default 20.04)
- PHP Version (default 8.0)
- Database Image Mysql or Mariadb (default mariadb:10.6)

**Note**: For convenience, you could also checkout a specific branch eg. PHP-7.4 and use those defaults (or adjust using same technique ^).

---

## Contents

- [Requirements](#requirements)
    - [Using MsSQL](#using-mssqlsqlsvr)
- [Install](#install)
    - [Clone - Where to put DockerLocal](#cloning-dockerlocal-into-your-project)
    - [Simple Installation Examples](#simple-install-examples)
        - [Ex: Basic](#ex-basic)
        - [Ex: With specifc port](#ex-with-specific-port)
        - [Ex: With New Empty Database](#ex--with-new-empty-database)
        - [Ex: With Remote-fetched Database](#ex--remote-fetched-database)
        - [Ex: With different root path](#ex--with-different-root-path)
- [Commands](#commands)
    - [Shut Down](#shut-down)
    - [Checking Logs](#checking-logs)
    - [NPM Command](#npm-command)
    - [Database Commands](#database-commands)
    - [SSH into containers](#ssh-into-the-containers)
    - [NVM-PM2 - restart pm2](#site-nvmpm2)
    - [Share your site](#share-your-site)
- [Configuration Files](#configuration-files)
    - [version overrides](#version-overrides)
        - [changing db_image type of an existing db](#changing-existing-db-image-version)
    - [port](#dockerlocalport)
    - [web-server-root](#dockerlocalweb-server-root)
    - [nginx.site.custom.conf](#dockerlocalnginxsitecustomconf)
    - [xdebug.custom.ini](#dockerlocalxdebugcustomini)
    - [database](#dockerlocaldatabase)
    - [databases.yml](#dockerlocaldatabasesyml)
    - [Dockerfile-template](#dockerlocaldockerfile-template)
        - [Dockerfile-template-custom](#customize)
    - [env-example.yml, env.yml](#dockerlocalenv-exampleyml-envyml)
    - [php7-fpm.site.conf](#dockerlocalphp7-fpmsiteconf)
    - [ecosystem.config.js](#dockerlocalecosystemconfigjs)
        - [nvm-pm2.sh script](#nvm-pm2-script)
        - [Accessing pm2 directly](#accessing-pm2-directly)
        - [PM2 + Laravel Horizon](#pm2--laravel-horizon)
        - [PM2 + Laravel Horizon + XDebug](#pm2--laravel-horizon--xdebug)
- [Add Database cnf files](#database-cnf-files)
- [Install NVM-PM2](#install-nvm-pm2)
- [How to use Xdebug](#use-xdebug)
    - [disable xdebug](#turn-off-xdebug)
- [Install ProxyLocal](#install-proxylocal)

---

## Requirements

- Bash 4+ on linux; MacOS default 3.2.57 is okay - recommend using [zsh](https://github.com/ohmyzsh/ohmyzsh) - install via curl
- Docker for Mac (or Docker && Docker-Compose) - tested with Docker version 20.10.0, build 7287ab3
    - docker-compose 1.29.2 (not v2 - disable in your terminal with: `docker-compose disable-v2` - [because docker-compose v1 uses underscores, not dashes,](https://stackoverflow.com/a/69519102/2100636) the scripts depend on)

#### Using MsSQL/SQLsvr?

DockerLocal does not support mssql/sqlsvr by default anymore - because it's not compatible with macs using m1 chips (docker does not support).

To enable MsSQL, use a custom Dockerfile. We have created a template you can copy with necessary packages:

```
cp Dockerfile-template-use-mssql-example Dockerfile-template-custom
```

**Note:** You can make any changes you want to the [Dockerfile-template-custom](#dockerlocaldockerfile-template) - to install different packages, etc.

[↑](#contents)

---

# Install

The following will cover how to install and use DockerLocal:

1) Where to clone
2) Simple installation examples

### Cloning DockerLocal into your project

Clone DockerLocal into **at the same level as your site's html folder**

```
- YourSite
    - DockerLocal
    - html/index.php
    - conf
```

Assuming the above,

```
cd ~/code/YourSite
git clone git@github.com:amurrell/DockerLocal.git
```

> **Note:** You can also use DockerLocal as a git submodule

[↑](#contents)

---

## Simple Install Examples

Control DockerLocal with shell commands. All the following examples rely upon:

1. Going to the commands folder. `cd DockerLocal/commands`
2. Understanding that shell scripts are triggered with a `./` preceeding the command, eg. `./site-up`
3. If you get prompted for a password, use your user's password for your computer!

Examples:

- [Ex: Basic](#ex-basic)
- [Ex: With specifc port](#ex-with-specific-port)
- [Ex: With New Empty Database](#ex--with-new-empty-database)
- [Ex: With Remote-fetched Database](#ex--remote-fetched-database)
- [Ex: With different root path](#ex--with-different-root-path)

[↑](#contents)

---

### Ex: Basic

This will install your site at [localhost:3000](http://localhost:3000) with no custom configuration (no database, default port, default webserver's root path eg. html/index.php or html/index.html).

- Run `./site-up`

[↑](#contents)

---

### Ex: With specific port

First, shutdown your previously loaded containers with `./site-down`. Skip if you have not ran `./site-up` yet.

Then, use `./site-up -p=XXXX` to specify a different port, eg. localhost:**XXXX**

**Tip:** [**create a port file**](#dockerlocalport) to maintain this project without having to type the switch -p for every command you run:

- `./site-down` first, shutdown containers if you already started them on another port
- `cd ../ && echo "3001" > port` this puts a file "port" in DockerLocal folder
- `cd commands && ./site-up` (no need to use -p switch)

Now it's running on your custom port 3001!

Go to [localhost:3001](http://localhost:3001)

[↑](#contents)

---

### Ex: With New Empty Database

To create a database, you can use the switch `-c=DB_NAME`. You only need to run this once.

To edit the database name your DockerLocal containers will use a [database configuration file](#dockerlocaldatabase). You can change this, but you will still need to use the `-c` switch to create new databases (one time).

- `./site-up -c=example_local_db`, where switch -c means create database. Run only 1 time to create.

You can safely shutdown and start up again and it remembers you're using that db (in php env vars) - because of that configuration file.

- `./site-down` to shut it down
- `./site-up` to start up again

[↑](#contents)

---

### With Remote-fetched Database

This example shows getting an sql dump of a remote database and importing it into *a local copy* in the mysql container.


Copy the `DockerLocal/databases-example.yml` to [`DockerLocal\databases.yml`](#dockerlocaldatabasesyml) and fill it out with your remote host information.

```
./site-up
```

[↑](#contents)

---

### With Different Root Path

If your project's root path for the public website files are in a different folder, you can configure that via the [`DockerLocal/web-server-root` file](#dockerlocalweb-server-root).

You can create this file initially with:

`./site-up -w=/var/www/site/app/public`

The first time you run that, it will create your configuration file. After that, it will only override that file if you pass -w again. To permanently change it, do so in the configuration file.

[↑](#contents)

----

## Commands

### Shut down

- `cd DockerLocal/commands`
- `./site-down`

#### Proxy Down

- `cd ~/vhosts/ProxyLocal/commands`
- `./proxy-down`

[↑](#contents)

---

### Checking Logs

If you want to check your log files, you can find them in `DockerLocal/logs`.

Your queue logs, access.log, php_error_log.log and error.log are all in that folder.

For quick tailing of the logs, you can use the `DockerLocal/commands` for `./site-logs`:

Ex: In your code

```
error_log(json_encode($myObject));
```

Ex: In your terminal, in `DockerLocal/commands`:

```
./site-logs     # All the logs are tailed
./site-logs -p  # Only php_error_log is tailed
./site-logs -e  # Only error_log is tailed
./site-logs -a  # Only access.log is tailed
./site-logs -h  # Help to find what the switches are
```


[↑](#contents)

---

### NPM Command

If you have a nested project that uses nvm & npm to build, you can run `./site-npm` with some options `-p=<path>` and `-n=<commands>`.

This makes it easier to install & run npm commands from the DockerLocal/commands folder.

```
## where 'my-app' is a folder at the root of your project.
## inside your container it would be at /var/www/site/my-app
./site-npm -p="my-app" -n="npm install && npm run development"
```

**Configuration Helper:** To save you time from having to specify the path all the time, save a file in `DockerLocal/app-path` with the path in it. eg. my-app

```
# from your terminal, at root of project:
echo "my-app" > DockerLocal/app-path
```

[↑](#contents)

---

### Database Commands

#### Create

- `cd DockerLocal/commands`
- `./site-db -c=example_database_name`

#### Use Locally Created DB

- `cd DockerLocal/commands`
- `./site-db -l=example_database_name` (if DockerLocal/database exists, the -l switch is not needed)

#### Use a remote database to create local db

- setup databases.yml by copying contents from DockerLocal/databases-example.yml
- `cd DockerLocal/commands`
- `./site-up` this will create a db-name.sql.remote.dump file, one time.

#### Re-fetch remote database to update local db (needs databases.yml).

- ensure databases.yml is up to date
- `cd DockerLocal/commands`
- `./site-db`

#### Export local database

1. If you don't know then name of your current database:
    - `cat DockerLocal/database`

1. If you want to see all databases you have locally:
    - `cd DockerLocal/commands` && `./site-ssh -h=mysql` && `show databases;`

1. If you know the name of your local db then:
    - `cd DockerLocal/commands`
    - `./site-db -d=your_db`

    This generates a file `DockerLocal/data/dumps/your_db.sql.dump` which you may want to rename so you wont write over this from subsequent dumps.

1. If you want this dump to include add/drop SQL:

    - `cd DockerLocal/commands`
    - `./site-db -d=your_db -a=true`

#### Import a file ( including create database sql )

- `cd DockerLocal/commands`
- `./site-db -f=import-complete.sql`

#### Import a file to an existing local db

- `cd DockerLocal/commands`
- `./site-db -i=name_of_local_db -f=import-partial.sql`

[↑](#contents)

---

### SSH into the containers

- `./site-ssh -h=mysql` and you'll be in mysql app as root user of mysql
- `./site-ssh -h=mysqlroot` to get into the container as root shell user. Can do `mysql -u root -p1234` to get into mysql app.
- `./site-ssh -h=web` && `cd /var/www/site/` to see your project. Run commands that might create files (ie. php artisan for laravel projects) as this www-data user.
- `./site-ssh -h=webroot` to get into the web container as root. Good for looking at confs etc `cd /etc/php/7.0/fpm/pool.d` for php-fpm conf, or `cd /etc/nginx/` for nginx conf
- `./site-ssh -h=memcached` .. there's really no reason to be here.

- `./site-ssh -h=web -c='cat /etc/passwd' where -c is a command to pass into the web container. Notice the difference between using single quotes. ie `-c="$(whoami)"` and `-c='$(whoami)'`.

[↑](#contents)

---

### Share your site

Requires Ngrok

- `cd DockerLocal/commands`
- `./site-ngrok`

#### Install ngrok

- [Download ngrok](https://ngrok.com/download)
- Unzip it to your **Applications** directory
- `ln -s /Applications/ngrok /usr/local/bin/ngrok`

[↑](#contents)

---

### site-nvmpm2

You can use nvm (at a [specific version](#version-overrides)) and pm2 (globally installed) with DockerLocal - they are already installed via the [`Dockerfile-Template`](#dockerlocaldockerfile-template).

If a [`DockerLocal/ecosystem.config.js`](#dockerlocalecosystemconfigjs) file exists, which is a configuration file for pm2, then also the [`site-up`](#ex-basic) command will `pm2 start` for you.

Additionally, running `./site-nvmpm2` manually will trigger a `pm2 restart all` if the ecosystem file exists.

Often times, you need to restart pm2 servers to catch changes to the code that is running inside the queues.

Eg. Laravel jobs will need you to reload workers (or horizon) after making changes to the code. Running `./site-nvmpm2` will `pm2 restart all`.

**Example: Restart all servers**

```
cd DockerLocal/commands
./site-nvmpm2
```

**Example: Manually access pm2 commands**

```
cd DockerLocal/commands
./site-ssh -h=web
cd ~
pm2 list all
```

[↑](#contents)

---

## Configuration Files

### Version Overrides

You can use the defaults or choose a different version for:
- **ubuntu** & **php** & **nodejs** versions in the `Dockerfile-template`. Variables (used in the file) are:
    - UBUNTU_VERSION
    - PHP_VERSION
    - NVM_VERSION
- **mysql or mariadb** version in `docker-compose-custom.yml` for the mysql image. Variable (used in the file) is:
    - DB_IMAGE

You can see the default configs in `DockerLocal/versions` in the form of files:

```
DockerLocal
- versions
    - php-version
      > 7.4
    - ubuntu-release-name
      > focal
    - ubuntu-version
      > 20.04
    - db-image
      > mariadb:10.5.8
    - nvm-version (nodejs version)
      > 16.14.2
```

If you `cat versions/php-version` you'll see the contents are just the version:

```
8.0
```

You can overide any of these by copying the file and renaming to prepend override. Eg.

```
echo "7.4" > versions/override-php-version
```

#### Changing existing DB image version

If you have an **existing database with data in it** using one image (eg. mysql) and you plan to switch to another (eg. mariadb), then you will need to backup your database, remove the docker volume, re-import your data.

**Note:** This is not an issue if you are changing the version of the same db image type (eg. mariadb:10.5.8 -> mariadb:10.6).

Here are the steps:

1. Get a backup SQL dump of your current setup

    - `./site-db -d=your_db_name`
    - `cd DockerLocal/data/dumps`
    - `mv` `your_db_name.sql.dump` or whatever it's called to `before_db_image_upgrade.sql`

2. Turn off the docker containers if running - `./site-down`.

3. Remove the data volume - make sure you have a backup!

    ```
    [sudo] docker volume ls
    see which one it is... eg. dockerlocal{PORT}-mysql-data-{PORT}
    [sudo] docker volume rm <name-of-volume>
    ```

3. Make the version change - eg. `echo "mariadb:10.6" > versions/override-db-image`

4. Turn back on `./site-up` - then create a db again `./site-up -c=your_db_name`

5. Import: `./site-db -i=your_db_name -f=before_db_image_upgrade.sql`


[↑](#contents)

---

### DockerLocal/port

If you would like to create a default custom port (other than 3000) for all commands in this project, create a port file.

The port in the command refers to localhost:**port** and it is used in DockerLocal by all the containers (to create their mapped ports and container names).

- `cd DockerLocal`
- `echo "3001" > port`

Of course, you can still override this default by using the `-p` switch.

So, your commands would be so simple:

```
./site-up
./site-db
./site-ssh -h=web
./site-down
```

[↑](#contents)

---

### DockerLocal/web-server-root

The default is root path is `/var/www/site/html`, which assumes that you have an `index.php` or `index.html` file directly in your `html` folder.

What if your project was different?

```
- YourSite
    - DockerLocal
    - app/public/index.php
    - conf
```

You can create this file initially with:

`./site-up -w=/var/www/site/app/public`

The first time you run that, it will create your configuration file. After that, it will only override that file if you pass -w again. To permanently change it, do so in the configuration file.

To confirm that your path is loaded correctly, you can check your [`DockerLocal\nginx.site.computed.conf`](#dockerlocalnginxsitecomputedconf) file that is generated from running `./site-up`. You should see the `root YOURPATH` line in your nginx server block.

[↑](#contents)

---

### DockerLocal/xdebug.custom.ini

Use the file `xdebug.custom.ini` to override `xdebug.ini`. If you don't have it, create it. Like all overriding/custom configuration, it will not be version controlled.

Your custom file (or the default file if no custom is set) will be computed into `xdebug.computed.ini` by the `site-up` command and then referenced in the `Dockerfile-Template` to add xdebug config to your project.

#### Turn off xdebug

If you want to turn off xdebug, change the line `xdebug.mode=develop,debug` to `xdebug.mode=off` in the file `DockerLocal/xdebug.custom.ini` (if you don't have that file, create it by copying `DockerLocal/xdebug.ini`). After changing this custom file, always run `./site-up` again.

You can find information about [how to use xdebug here](#use-xdebug).

[↑](#contents)

---

### DockerLocal/nginx.site.custom.conf

Use this file to override the nginx.site.conf. You can start by copying the nginx.site.conf file and then making your edits.

The nginx.site.computed.conf file is basically the same as your custom, but with variables computed.

The following variables are available to use in your nginx.site.custom.conf file:

- **SITE_DOMAIN** - this will use SITE_DOMAIN for those running proxylocal, or smartly use WEB_PORT if not
- **WEB_SERVER_ROOT** - this is your web servers root path. See [DockerLocal/web-server-root](#dockerlocalweb-server-root)

[↑](#contents)

---

### DockerLocal/database

After running the `-c=DB_NAME` command, you will have a file in `DockerLocal/database` with the `DB_NAME` in it.

You can change this out by editing the file. To create new databases, you will still use the `-c` switch (1 time).

You can use -l switch to specify a different local database than the one saved in DockerLocal/database - this just overrides which one to use, but doesn't edit the file.

To confirm your `database` file is being read correctly, you can check the `DockerLocal/env-custom.yml` file for your DB_NAME.

To confirm your `database` exists, you can ssh into the mysql container: `./site-ssh -h=mysql` and `show databases;`

[↑](#contents)

---

### DockerLocal/databases.yml

If you have a remote database to use as a source to populate your local database, create a databases.yml

- Copy databases-example.yml to databases.yml

Ex:
```
databases:
    host:
    user:
    pass:
    port: 3306
    3001: example_com
```

[↑](#contents)

---

### DockerLocal/env-example.yml, env.yml

- This file is for PHP env vars. Make your own as env.yml if you need to customize it.
- Can use for local database connection
- Variables you can use:

    - `DATABASE_NAME` (Will be populated by matching site-port in databases.yml, or `-c` and `-l` switch values, for creating or using a locally created database)
    - `DATABASE_HOST` (relative to web container: `mysql`)
    - `DATABASE_PORT` (relative to host machine: your localhost:**port** + 3306, eg. `6307` if port is 3001)

See the output of your env vars in php7-fpm.site.custom.conf

Ex:
```
envs:
    DL_DB_NAME: DATABASE_NAME
    DL_DB_USER: root
    DL_DB_PASS: 1234
    DL_DB_HOST: mysql
    DL_DB_PORT: 3306
    DL_DB_LOCAL_PORT: DATABASE_PORT
```

php7 conf:
```
env[DL_DB_NAME]="example_com"
env[DL_DB_USER]="root"
env[DL_DB_PASS]="1234"
env[DL_DB_HOST]="mysql"
env[DL_DB_PORT]="3306"
env[DL_DB_LOCAL_PORT]="6307"
```

[↑](#contents)

---

### DockerLocal/php7-fpm.site.conf

This is a template file, for the outputted `php7-fpm.site.custom.conf`.
Ensure you keep `;ENV` in your template for env vars to populate there. The rest is yours to modify!

> **NOTE:** If you modify this file, it will look like unstaged file changes.

> **TODO:** change php7-fpm.site.custom.conf to be a computed file, and allow for edits to get stored in the custom file.)

[↑](#contents)

---

### DockerLocal/Dockerfile-template

The "Web" container is defined by this `Dockerfile-template`.

- it contains variables to [help with versioning](#version-overrides): `UBUNTU_VERSION` and `PHP_VERSION`
- it relies on the `./site-up` script to compute the variables to create an untracked file: `Dockerfile-computed`
    - this is what gets used by docker-compose.

#### Customize

If you need to install any other php libraries or modify this template beyond the version overrides, feel free to create a copy, edit and save as `Dockerfile-template-custom`, which will get used over `Dockerfile-template`.

[↑](#contents)

---

## DockerLocal/ecosystem.config.js

This file is a special configuration file for pm2, a process manager and npm package.

PM2 is useful for projects that have workers, running on queues using CLI - typically asynchronous. An example is laravel worker queues for jobs (or running them through laravel horizon).

#### nvm-pm2 script

PM2 is included with DockerLocal via the `nvm-pm2.sh` script that is ran by both the [`Dockerfile-Template`](#dockerlocaldockerfile-template) && [`site-up`](#ex-basic) command after the docker containers are booted.

- The **first** call installs nvm at the [`nvm-version`](#version-overrides) (node js version). It also installs pm2 globablly.
- The **second** call, from [`site-up`](#ex-basic) will `pm2 start` if you have a `DockerLocal/ecosystem.config.js`
- You can **manually call it** any time with [`./site-nvmpm2`](#site-nvmpm2) in the [`DockerLocal/commands`](#commands) folder, which will basically `pm2 restart all`, if ecosystem.config.js is present.

To access commands directly, see next section, [Accessing pm2 directly](#accessing-pm2-directly).

For help with the contents of ecosystem.config.js, see:

- [PM2 + Laravel Horizon](#pm2--laravel-horizon)
- [PM2 + Laravel Horizon + XDebug](#pm2--laravel-horizon--xdebug)
- Perform your own google searches, since this is a configuration for PM2 specifically.

[↑](#contents)

---

### Accessing pm2 directly

You can `site-ssh` to access pm2 commands directly.

```
./site-ssh -h=web
cd ~
pm2 list all
```

[↑](#contents)

---

### PM2 + Laravel Horizon

If you are planning to use pm2 to run horizon, here's an example configuration for that:

```json
{
      name: "laravel-horizon",
      cwd: "./site/app",
      interpreter: "php",
      script_path: "/var/www/site/app/artisan",
      script: "artisan",
      args: "horizon",
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: "1G",
      merge_logs: true,
      out_file: "/var/www/site/DockerLocal/logs/horizon.log",
      error_file: "/var/www/site/DockerLocal/logs/horizon.log",
      log_date_format: "MM/DD/YYYY HH:mm:ss",
    }
```

[↑](#contents)

---

### PM2 + Laravel Horizon + XDebug

If you are wanting to use xdebug to monitor CLI running queue workers eg. in laravel via horizon, I caution that horizon runs every second which may become a very difficult testing environment... but it can be done. Here's an example ecosystem file entry to accomplish running xdebug on horizon via pm2.

```jsonc
{
    name: "xdebug-horizon",
    cwd: "./site/app",
    interpreter: "php",
    script_path: "/var/www/site/app/artisan",
    script: "artisan",
    args: "-dxdebug.remote_autostart=1 -dxdebug.remote_host=host.docker.internal -dxdebug.remote_port=9000 -dxdebug.remote_enable=1 horizon",
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: "1G",
    merge_logs: true,
    out_file: "/var/www/site/DockerLocal/logs/horizon.log",
    error_file: "/var/www/site/DockerLocal/logs/horizon.log",
    log_date_format: "MM/DD/YYYY HH:mm:ss",
},
```

[↑](#contents)

---

## Install nvm-pm2

You can use pm2 with this project, but it's a bit more manual.

Look at the documentation for the configuration file [DockerLocal/ecosystem.config.js](#dockerlocalecosystemconfigjs) for more information on how it install nvm-pm2 and setup config.

---

If you were tangentally looking how to install nvm on your local machine (not in the container), and do not want to use brew, here's how:

```
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash
. ~/.nvm/nvm.sh
. ~/.profile
. ~/.bashrc
. ~/.zshrc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

command -v nvm
```

[↑](#contents)

---

## Database cnf files

If you need to adjust settings eg. `my.cnf` for the database (mysql|mariadb) image, you can add `*.cnf` config files to `DockerLocal/data/custom/`.

**Note:** `options.cnf` is already in version control, but you can create any other files there and have them ignored - eg. my.cnf

How does it work? In the `docker-compose`, there's a shared volume which connects these files to the container's `/etc/mysql/conf.d`:

```
volumes:
...
- ./data/custom:/etc/mysql/conf.d
...
```

[↑](#contents)

---

## Use xdebug

Xdebug is a debugging tool that communicates with your IDE while listening to incoming requests to your application. It does all this on another `localhost:<port>` and with configuration. This means:

- your web application & server will need necessary packages - eg. php-xdebug.
- your web application / server will need necessary configuration - eg. in xdebug.ini (custom configuration available in [xdebug.custom.ini](#dockerlocalxdebugcustomini))
- your IDE will need an extension installed so that the debugger and the IDE can communicate
- your IDE may need configuration on how to connect to your debugger - eg. launch.json in vscode

So the first two items on the list are solved by DockerLocal by default!

- The `Dockerfile-template` has installed the php-xdebug package for your version.

- It also added the `xdebug.computed.ini` to appropriate location in the container. If you want to change settings, [read about using custom configuration file xdebug.custom.ini](#dockerlocalxdebugcustomini), which includes how to disable xdebug.

### Xdebug with VScode

To use xdebug with vscode & DockerLocal, simply:

1. Install the xdebugging extension for your IDE - eg. vscode needs a PHP X-debug extension if using a php debugger. eg. extension id: xdebug.php-debug
1. If you don't yet have a hidden  `.vscode` folder ("hidden" is indicated by leading `.`) - add one to your root repo `<your-project>/.vscode` so that it looks something like this:

    ```
    - your-project
        - .vscode
        - DockerLocal
        - html
            - your-code
    ```

1. add a `launch.json` file into this `.vscode` folder, or add just the configuration entry if you have a launch.json file already.

    Example: `launch.json`

    ```json
    {
        // Use IntelliSense to learn about possible attributes.
        // Hover to view descriptions of existing attributes.
        // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
        "version": "0.2.0",
        "configurations": [
            {
                "name": "Listen for Xdebug",
                "type": "php",
                "request": "launch",
                "port": 9003,
                "pathMappings": {
                "/var/www/site": "${workspaceFolder}"
                }
            }
        ]
    }
    ```

    Explanations of the configuration:

    - The `/var/www/site` in `"/var/www/site": "${workspaceFolder}"` references the path to your running application within DockerLocal web container - where php is running. `cd DockerLocal/commands && ./site-ssh -h=web` and you are in that same directory.
    - The `${workspaceFolder}` portion references the IDE vscode's folder for the project.
1. If you want to add `extensions.json` in your `.vscode` folder, so that they can be recommended to anyone who runs your code:

    ```json
    {
        "recommendations": [
            "xdebug.php-debug"
        ]
    }
    ```

### Use debugger in vscode

So once everything is setup, go to your debugger tab in vscode (looks like a play button with bug over it).

In the top left - it says "Run and debug" with a dropdown. In the dropdown, use the "Listen For Xdebug" which is going to mirror what you wrote in your launch.json if that is setup correctly.

Click the Play button. Now some controls appear centered at the top of vscode. It is "listening". Go trigger requests - visit your website, hit postman, whatever to hit your site.

It will stop at any break points and let you look at variables. You can step back, step forward, or click deeper into functions.


### Check logs

It's easy to see the xdebug logs due to the configuration setup in `Dockerfile-template` - we put the logs at `/var/www/site/DockerLocal/logs/xdebug.log`

You can use the DockerLocal command `./site-logs -x` to tail the x debug log as a shortcut for (tail -f xdebug.log)

Note that it will say `Could not connect to debugging client.` when you are not running the debugger in your IDE. Simply start a debug session and it will connect when you hit your project.

---

## Install ProxyLocal

[ProxyLocal](https://github.com/amurrell/ProxyLocal) - Sets up your hosts file + reverse proxy to access site on localhost:port **by domain**.

Steps (one time thing):

- git clone **ProxyLocal** in *vhosts* or equivalent so that it is at the same level as your sites
- create sites.yml from sites-example.yml, try: `3001: docker.example.com`
- go to ProxyLocal/commands and run ./proxy-up command
- do normal DockerLocal setup; now can use `./site-up -n=docker.example.com` or `./site-up` if you have a port file in your DockerLocal that matches an entry in sites.yml

Commands:

```
git clone git@github.com:amurrell/ProxyLocal.git
cd ProxyLocal/commands
# remember to make the sites.yml in ProxyLocal!
./proxy-up
```

The reverse proxy is running: [localhost](http://localhost)

### Config in ProxyLocal

#### ProxyLocal/sites.yml

While this file lives in ProxyLocal's repo, it helps the site commands by allowing `-n=docker.example.com` to be specified rather than a specific port.
This is great if you plan to run many sites with DockerLocal and don't want to remember each site's port.

Ex.
```
sites:
    3001: docker.example.com
```

By adding a `port: site` to sites.yml, you can go to your DockerLocal project and do `./site-up -p=port` or if you have a port file `./site-up` and it will automatically boot up ProxyLocal if not already running.

**Tip**: ProxyLocal handles nginx conf enabling - if you have to do it manually you can do `cd ProxyLocal/commands && ./proxy-nginx -p=3001` to enable nginx conf for site at port 3001 and `./proxy-nginx -p=3001 -d=true` to disable it.

#### ProxyLocal/databases.yml

You can use one databases.yml in ProxyLocal like this if all your data is at the same remote host, with same user/pass combo:

```
databases:
    host:
    user:
    pass:
    port: 3306
    3001: example_com
    3002: another_example_com
    3003: yet_another_example_com
```

Where the databases example_come, another_example_com, etc are remote and can all be accessed by the same host, user, pass, and port.
If you need specifics, you can still create a databases.yml per site and keep it in DockerLocal.

The Numbered Keys in that yaml represent the localhost:PORT and therefore corresponding mysql container to import the remote db into: dockerlocal3001-mysql-1
