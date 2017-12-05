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


Now **create a port file** to maintain this project without having to type the switch -p for every commands:

- `./site-down` to shutdown containers
- `cd DockerLocal && echo "3001" > port` 
- `cd commands && ./site-up` (no need to use -p switch)

Now it's running on your custom port 3001!

Go to [localhost:3001](http://localhost:3001)

#### With Empty Database

- `cd DockerLocal/commands`
- `./site-up -c=example_local_db`, where switch -c means create database

Great job! The site is running on localhost, database is created, and php env vars are adjusted to reflect this db name. Go to [localhost:3001](http://localhost:3001)

Look at generated DockerLocal/env-custom.yml and generated php7-fpm.site.custom.conf

- `./site-down` to shut it down
- `./site-up` to start up again, which it will use local db "example_local_db" because it is stored in DockerLocal/database (from using the -c switch before)

**Tip**: Can use -l switch to specify a different local database than the one saved in DockerLocal/database

#### With Remote-fetched Database used as source for Local DB

This will get a dump of a remote database and import it into a local copy in the mysql container.

```
#Copy DockerLocal/databases-example.yml to databases.yml and fill it out with your remote host information.
./site-up
```

Go to [localhost:3001](http://localhost:3001)

----

## Share your site (Requires ngrok)

- `cd DockerLocal/commands`
- `./site-ngrok`

#### Install ngrok

- [Download ngrok](https://ngrok.com/download)
- Unzip it to your **Applications** directory
- `ln -s /Applications/ngrok /usr/local/bin/ngrok`

## Shut down

- `cd DockerLocal/commands`
- `./site-down`

#### Proxy Down

- `cd ~/vhosts/ProxyLocal/commands`
- `./proxy-down`

## Database Commands

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

#### Import a file ( including create database sql )

- `cd DockerLocal/commands`
- `./site-db -f=import-complete.sql`

#### Import a file to an existing local db

- `cd DockerLocal/commands`
- `./site-db -i=name_of_local_db -f=import-partial.sql`

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
