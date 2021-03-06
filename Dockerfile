# Set the base image to ubuntu:18.04
FROM        ubuntu:18.04

# File Author / Maintainer
LABEL maintainer "Angela Murrell <me@angelamurrell.com>"

# Update the repository and install nginx and php7.3
ENV DEBIAN_FRONTEND=noninteractive 

RUN apt-get update && apt-get install -y nano && \
	apt-get install -y curl && \
	apt-get install -y sudo && \
	apt-get install -y wget && \
	apt-get install -y git && \
	apt-get install -y unzip && \
	apt-get install -y ruby-full && \
	apt-get install -y ufw && \
	apt-get install -y software-properties-common && \
	apt-get install -y apt-transport-https && \
	apt-get install -y nginx && \
	apt-get install -y unixodbc-dev

RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php && \
	apt-get update

RUN apt-get update && \ 
	apt-get -y --no-install-recommends install php7.3 && \
	apt-get -y --no-install-recommends install php7.3-fpm && \
	apt-get -y --no-install-recommends install apt-utils && \
	apt-get -y install freetds-bin tdsodbc unixodbc unixodbc-dev && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Set which PHP we want to use
RUN sudo update-alternatives --set php /usr/bin/php7.3
RUN sudo update-alternatives --set phar /usr/bin/phar7.3
RUN sudo update-alternatives --set phar.phar /usr/bin/phar.phar7.3

# add msodbcsql packages
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list

# install msodbcsql and associated tools
RUN apt-get update
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17
RUN ACCEPT_EULA=Y apt-get install -y mssql-tools

# # add msssql-tools to path 
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

# Install more stuff
RUN	apt-get update && \
	apt-get -y install php7.3-curl && \
	apt-get -y install php7.3-mysql && \
	apt-get -y install php-pear && \
	apt-get -y install php7.3-dev && \
	apt-get -y install libcurl3-openssl-dev && \
	apt-get -y install libyaml-dev && \
	apt-get -y install php7.3-zip && \
	apt-get -y install php7.3-mbstring && \
	apt-get -y install php7.3-gd && \
	apt-get -y install php7.3-sybase && \
	apt-get -y install php7.3-memcached && \
	apt-get -y install php7.3-pgsql && \
	apt-get -y install php7.3-xml && \
	apt-get -y install php7.3-intl && \
	apt-get -y install php7.3-bcmath && \
	apt-get -y install php7.3-redis && \
	apt-get -y install php7.3-gd

RUN pecl -d php_suffix=7.3 install sqlsrv
RUN pecl uninstall -r sqlsrv

RUN pecl -d php_suffix=7.3 install pdo_sqlsrv
RUN pecl uninstall -r pdo_sqlsrv

RUN pecl -d php_suffix=7.3 install redis
RUN pecl uninstall -r redis

RUN pecl -d php_suffix=7.3 install yaml-2.2.1
RUN pecl uninstall -r yaml-2.2.1

RUN echo extension=pdo_sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-pdo_sqlsrv.ini
RUN echo extension=sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/20-sqlsrv.ini

# copy 30-pdo_sqlsrv.ini to some locations for loading
RUN cp /etc/php/7.3/cli/conf.d/20-sqlsrv.ini /etc/php/7.3/fpm/conf.d
RUN cp /etc/php/7.3/cli/conf.d/30-pdo_sqlsrv.ini /etc/php/7.3/fpm/conf.d

# export var for nano to work in command line
ENV TERM xterm

# Set workdir
WORKDIR /var/www/

# Add site directory
RUN mkdir /var/www/site

# Copy a configuration file from the current directory
ADD nginx.site.computed.conf /etc/nginx/sites-available/

# Remove symbolic link to default enabled nginx site in sites-enabled
RUN rm /etc/nginx/sites-enabled/default

# Make Symbolic link to enable the site
RUN ln -s /etc/nginx/sites-available/nginx.site.computed.conf /etc/nginx/sites-enabled/

# Append "daemon off;" to the configuration file
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# Append source brc alias to the bashrc profile file
RUN echo 'alias brc="source /root/.bashrc"' >> /root/.bashrc

# Copy a configuration file from the current directory
ADD php7-fpm.site.custom.conf /etc/php/7.3/fpm/pool.d

# Copy the nvm-pm2 script over
ADD nvm-pm2.sh /var/www

# daemon off for php also
RUN sed -i "/;daemonize = .*/c\daemonize = no" /etc/php/7.3/fpm/php-fpm.conf && \
	sed -i "/variables_order = .*/c\variables_order = \"EGPCS\"" /etc/php/7.3/fpm/php.ini && \
	sed -i "/pid = .*/c\;pid = /run/php/php7.3-fpm.pid" /etc/php/7.3/fpm/php-fpm.conf

# Remove pool.d/www.conf
RUN rm /etc/php/7.3/fpm/pool.d/www.conf

# Adjust www-data
RUN usermod -u 1000 www-data

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Start memcached?
#RUN service memcached start

# Set the default command to execute when creating a new container
# The following runs FPM and removes all its extraneous log output on top of what your app outputs to stdout
CMD service php7.3-fpm start && service nginx start && /usr/sbin/php-fpm7.3 -F -O 2>&1 | sed -u 's,.*: \"\(.*\)$,\1,'| sed -u 's,"$,,' 1>&1
# CMD service php7.3-fpm start && service nginx start 
