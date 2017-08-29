# DockerLocal

**DockerLocal** is used for setting up a site to be served on localhost:PORT

**DockerLocal** runs on docker containers - nginx + php7.0-fpm, memcached, mysql and your project's web application files.

---

## Requirements

- Docker (Tested with Docker version 17.03.1-ce, build c6d412e)
- Docker-Compose (Tested with docker-compose version 1.12.0, build b31ff33)
- Bash 4+ (MacOS default 3.2.57, needs brew install)

#### Update Bash for MacOS
```
/bin/bash --version
brew install bash
/usr/local/bin/bash --version
```

## Cloning DockerLocal into your project

Clone DockerLocal into **one level above your site's html folder** (assumes html/index.php) (configurable)

Assuming `/path/to/your/website/html/index.php` exists

```
cd /path/to/your/website/
git clone git@github.com:amurrell/DockerLocal.git
```

## Simple Install

#### No Database

- `cd DockerLocal/commands`
- `./site-up`

Great job! The site is running on localhost. Go to [localhost:3000](http://localhost:3000)

**Tip**: use `./site-up -p=XXXX` to specify a different localhost:**port**

#### With Empty Database

- `cd DockerLocal/commands`
- `./site-up -p=3001 -c=example_local_db`

Great job! The site is running on localhost. Go to [localhost:3001](http://localhost:3001)

**Tip**: `-c` switch is the name of the local database to **create**

- `./site-down -p=3001` to shut it down
- `./site-up -p=3001 -l=example_local_db` to start up again use `-l` switch to **use** local db "example_local_db"

#### With Remote-fetched Database used as source for Local DB

This will get a dump of a remote database and import it into a local copy in the mysql container.

```
cd DockerLocal/commands
# need to configure and put a databases.yml into DockerLocal!
# choose a port that matches databases.yml entry for `PORT: DB NAME` eg 3001 from `3001: example_com`
./site-up -p=3001
```

Go to [localhost:3001](http://localhost:3001)

----

## Share your site (Requires ngrok)

- `cd DockerLocal/commands`
- `./site-ngrok -p=3001`

#### Install ngrok

- [Download ngrok](https://ngrok.com/download)
- Unzip it to your **Applications** directory
- `ln -s /Applications/ngrok /usr/local/bin/ngrok`

## Shut down

- `cd DockerLocal/commands`
- `./site-down -p=3001`

#### Proxy Down

- `cd ~/vhosts/ProxyLocal/commands`
- `./proxy-down`

## Database Commands

#### Create

- `cd DockerLocal/commands`
- `./site-db -p=3001 -c=example_database_name`

#### Use Locally Created DB

- `cd DockerLocal/commands`
- `./site-db -p=3001 -l=example_database_name`

#### Use a remote database to create local db

- setup databases.yml
- `cd DockerLocal/commands`
- `./site-up -p=3001` if you have never ran it before. This will create a db-name.sql.remote.dump file.

#### Re-fetch remote database to update local db (needs databases.yml).

- ensure databases.yml is up to date
- `cd DockerLocal/commands`
- `./site-db -p=3001`

#### Import a file ( including create database sql )

- `cd DockerLocal/commands`
- `./site-db -p=3001 -f=import-complete.sql`

#### Import a file to an existing local db

- `cd DockerLocal/commands`
- `./site-db -p=3001 -i=name_of_local_db -f=import-partial.sql`

----

## Config Files

#### DockerLocal/port

If you would like to create a default custom port (other than 3000) for all commands in this project, create a port file.

The port in the command refers to localhost:**port** and it is used in DockerLocal by all the containers (to create their mapped ports and container names).

- `cd DockerLocal`
- `echo "3001" > port`

Of course, you can still override this default by using the `-p` switch.

So, your commands would be so simple:

```
./site-up
./site-db
./site-ngrok
./site-ssh -h=web
./site-down
```

#### DockerLocal/databases.yml

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

#### DockerLocal/env-example.yml, env.yml

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

#### DockerLocal/nginx.site.conf

You can modify your root folder or other nginx configuration needs in this file.

Change the *root* folder from html and *index* from index.php in this file!

ex:
```
root /var/www/site/html;
index index.php index.html;
```

#### DockerLocal/php7-fpm.site.conf

This is a template file, for the outputted `php7-fpm.site.custom.conf`.
Ensure you keep `;ENV` in your template for env vars to populate there. The rest is yours to modify!


#### DockerLocal/Dockerfile

The "Web" container is defined by this DockerFile.

If you need to install any other php libraries or what not, feel free to create a copy, edit and save as `Dockerfile-custom`, which will get used over Dockerfile.

---

## Install ProxyLocal

[ProxyLocal](https://github.com/amurrell/ProxyLocal) - Sets up your hosts file + reverse proxy to access site on localhost:port **by domain**.

Steps (one time thing):

- git clone **ProxyLocal** in *vhosts* or equivalent so that it is at the same level as your sites
- create sites.yml from sites-example.yml, try: `3001: docker.example.com`
- go to ProxyLocal/commands and run ./proxy-up command
- do normal DockerLocal setup; now can use `./site-up -n=docker.example.com`

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

#### ProxyLocal/databases.yml

You can use one databases.yml in ProxyLocal like this:

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
