# DockerLocal

**DockerLocal** is used for setting up a LEMP site to be served on localhost:PORT

**DockerLocal** runs on docker containers - nginx + php7.3-fpm, memcached, redis, mysql and your project's web application files. Provides customization for configuring the Dockerfile, nginx, php-fpm, and managing databases.

> **Note:** Your DockerLocal containers can also be used with [ProxyLocal](https://github.com/amurrell/ProxyLocal) for a local DNS of all your DockerLocal projects so that you can run your sites locally at custom domains, like docker.yoursite.com and docker.anothersite.com

---

## Contents

- [Requirements](#requirements)
    - [Update Bash](#update-bash)
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
    - [Database Commands](#database-commands)
    - [SSH into containers](#ssh-into-the-containers)
    - [Share your site](#share-your-site)
- [Configuration Files](#configuration-files)
    - [port](#dockerlocalport)
    - [web-server-root](#dockerlocalweb-server-root)
    - [nginx.site.custom.conf](#dockerlocalnginxsitecustomconf)
    - [database](#dockerlocaldatabase)
    - [database.yml](#dockerlocaldatabaseyml)
    - [Dockerfile-custom](#dockerlocaldockerfile)
    - [env-example.yml, env.yml](#dockerlocalenv-exampleyml-envyml)
    - [php7-fpm.site.conf](#dockerlocalphp7-fpmsiteconf)
    - [ecosystem.config.js](#dockerlocalecosystemconfigjs)
- [Install NVM-PM2](#install-nvm-pm2)
- [Install ProxyLocal](#install-proxylocal)
---

## Requirements

- Bash 4+ (MacOS default 3.2.57, needs brew install), or Zsh
- Docker for Mac (or Docker && Docker-Compose) - tested with Docker version 20.10.0, build 7287ab3

#### Update Bash
```
/bin/bash --version
brew install bash
/usr/local/bin/bash --version
```

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

---

### Ex: Basic

This will install your site at [localhost:3000](http://localhost:3000) with no custom configuration (no database, default port, default webserver's root path eg. html/index.php or html/index.html).

- Run `./site-up`

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

---

### Ex: With New Empty Database

To create a database, you can use the switch `-c=DB_NAME`. You only need to run this once.

To edit the database name your DockerLocal containers will use a [database configuration file](#dockerlocaldatabase). You can change this, but you will still need to use the `-c` switch to create new databases (one time).

- `./site-up -c=example_local_db`, where switch -c means create database. Run only 1 time to create.

You can safely shutdown and start up again and it remembers you're using that db (in php env vars) - because of that configuration file.

- `./site-down` to shut it down
- `./site-up` to start up again

---

### With Remote-fetched Database

This example shows getting an sql dump of a remote database and importing it into *a local copy* in the mysql container.


Copy the `DockerLocal/databases-example.yml` to [`DockerLocal\databases.yml`](#dockerlocaldatabasesyml) and fill it out with your remote host information.

```
./site-up
```

---

### With Different Root Path

If your project's root path for the public website files are in a different folder, you can configure that via the [`DockerLocal/web-server-root` file](#dockerlocalweb-server-root).

You can create this file initially with:

`./site-up -w=/var/www/site/app/public`

The first time you run that, it will create your configuration file. After that, it will only override that file if you pass -w again. To permanently change it, do so in the configuration file.

----

## Commands

### Shut down

- `cd DockerLocal/commands`
- `./site-down`

#### Proxy Down

- `cd ~/vhosts/ProxyLocal/commands`
- `./proxy-down`

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

---

### SSH into the containers

- `./site-ssh -h=mysql` and you'll be in mysql app as root user of mysql
- `./site-ssh -h=mysqlroot` to get into the container as root shell user. Can do `mysql -u root -p1234` to get into mysql app.
- `./site-ssh -h=web` && `cd /var/www/site/` to see your project. Run commands that might create files (ie. php artisan for laravel projects) as this www-data user.
- `./site-ssh -h=webroot` to get into the web container as root. Good for looking at confs etc `cd /etc/php/7.0/fpm/pool.d` for php-fpm conf, or `cd /etc/nginx/` for nginx conf
- `./site-ssh -h=memcached` .. there's really no reason to be here.

- `./site-ssh -h=web -c='cat /etc/passwd' where -c is a command to pass into the web container. Notice the difference between using single quotes. ie `-c="$(whoami)"` and `-c='$(whoami)'`.

---

### Share your site

Requires Ngrok

- `cd DockerLocal/commands`
- `./site-ngrok`

#### Install ngrok

- [Download ngrok](https://ngrok.com/download)
- Unzip it to your **Applications** directory
- `ln -s /Applications/ngrok /usr/local/bin/ngrok`

----

## Configuration Files

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

---

### DockerLocal/nginx.site.custom.conf

Use this file to override the nginx.site.conf. You can start by copying the nginx.site.conf file and then making your edits.

The nginx.site.computed.conf file is basically the same as your custom, but with variables computed. 

The following variables are available to use in your nginx.site.custom.conf file:

- **SITE_DOMAIN** - this is only going to work if you have ProxyLocal running
- **WEB_SERVER_ROOT** - this is your web servers root path. See [DockerLocal/web-server-root](#dockerlocalweb-server-root)

---

### DockerLocal/database

After running the `-c=DB_NAME` command, you will have a file in `DockerLocal/database` with the `DB_NAME` in it. 

You can change this out by editing the file. To create new databases, you will still use the `-c` switch (1 time).

You can use -l switch to specify a different local database than the one saved in DockerLocal/database - this just overrides which one to use, but doesn't edit the file.

To confirm your `database` file is being read correctly, you can check the `DockerLocal/env-custom.yml` file for your DB_NAME.

To confirm your `database` exists, you can ssh into the mysql container: `./site-ssh -h=mysql` and `show databases;`

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

---

### DockerLocal/php7-fpm.site.conf

This is a template file, for the outputted `php7-fpm.site.custom.conf`.
Ensure you keep `;ENV` in your template for env vars to populate there. The rest is yours to modify! 

> **NOTE:** If you modify this file, it will look like unstaged file changes. 

> **TODO:** change php7-fpm.site.custom.conf to be a computed file, and allow for edits to get stored in the custom file.)

---

### DockerLocal/Dockerfile

The "Web" container is defined by this DockerFile.

If you need to install any other php libraries or what not, feel free to create a copy, edit and save as `Dockerfile-custom`, which will get used over Dockerfile.

---

### DockerLocal/ecosystem.config.js

This file is a special configuration file for using with pm2, a process manager. PM2 is useful for projects that have workers, like laravel worker queues. 

You can take advantage of the `DockerLocal\nvm-pm2` shell command that will install nvm and pm2 for you. 

Here's how:

```
./site-ssh -h=webroot
cd /var/www
./nvm-pm2

# logout

# log back in (nvm will be sourced in your profile now)
./site-ssh -h=webroot
pm2 start
```

> **Note**: You have to run this stuff above every time you power up your containers. You will also want to re-run pm2 (eg pm2 restart) when you've made changes to your code that would affect these queues.

---

## Install nvm-pm2

You can use pm2 with this project, but it's a bit more manual. Look at the documentation for the configuration file [DockerLocal/ecosystem.config.js](#dockerlocalecosystemconfigjs) for more information.

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

The Numbered Keys in that yaml represent the localhost:PORT and therefore corresponding mysql container to import the remote db into: dockerlocal3001_mysql_1
