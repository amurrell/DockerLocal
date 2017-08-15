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

## Get Started

- `git clone git@github.com:amurrell/DockerLocal.git` into one level above your site's html folder (assumes html/index.php) (can be tweaked/reconfigured).
- `cd DockerLocal/commands`
- `./site-up` (add `-p=PORT` to specify a port)

Great job! The site is running on localhost. Go to [localhost:3000](http://localhost:3000)

---

# ProxyLocal, DockerLocal's sibling

[ProxyLocal](https://github.com/amurrell/ProxyLocal) creates a reverse-proxy to allow you to use domains with any projects you have running on localhost:PORT

- If using ProxyLocal with a sites.yml file, you can use the `./site-up` command with `-n=docker.yourproject.com -s=path/to/ProxyLocal/sites.yml` and it will assume the correct port for your DockerLocal setup too.
- Also, ProxyLocal has specific DockerLocal instructions at [localhost/DockerLocal](http://localhost/DockerLocal) if it's running!