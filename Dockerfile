FROM ubuntu AS laravel
MAINTAINER Egor Vakhrushev

ENV DOMAIN=laravel

RUN apt-get update

RUN apt-get install -y \
			git \
			vim \
			software-properties-common \
			python-software-properties \
			curl \
			wget \
			iputils-ping \
			net-tools

# Install nginx
RUN apt-get install -y nginx
COPY laravel.conf /opt

# Install PHP
RUN LC_ALL=C.UTF-8 add-apt-repository -y -u ppa:ondrej/php
RUN apt-get update
RUN apt-get install -y \
			php7.2-fpm \
			php7.2-cli \
			php7.2-common \
			php7.2-mbstring \
			php7.2-gd \
			php7.2-intl \
			php7.2-xml \
			php7.2-mysql \
			php7.2-pgsql \
			php7.2-opcache \
			php7.2-zip \
			php7.2-dev \
			php7.2-curl \
			php7.2-sqlite3
RUN mkdir -p /run/php

# Update PHP config
RUN sed -i -- "s/;clear_env = no/clear_env = no/g" /etc/php/7.2/fpm/pool.d/www.conf
RUN sed -i -- "s/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g" /etc/php/7.2/fpm/pool.d/www.conf
RUN sed -i -- "s/pm.start_servers = 2/pm.start_servers = 4/g" /etc/php/7.2/fpm/pool.d/www.conf
RUN sed -i -- "s/pm.min_spare_servers = 1/pm.min_spare_servers = 4/g" /etc/php/7.2/fpm/pool.d/www.conf
RUN sed -i -- "s/pm.max_spare_servers = 3/pm.max_spare_servers = 16/g" /etc/php/7.2/fpm/pool.d/www.conf
RUN sed -i -- "s/pm.max_requests = 500/pm.max_requests = 1000/g" /etc/php/7.2/fpm/pool.d/www.conf
RUN sed -i -- "s/pm.max_children = 5/pm.max_children = 128/g" /etc/php/7.2/fpm/pool.d/www.conf

# Install composer
RUN cd /opt && curl -sS https://getcomposer.org/installer -o composer-setup.php && php composer-setup.php --install-dir=/usr/bin --filename=composer && rm composer-setup.php

# Install nodejs
RUN cd /opt && curl -sL https://deb.nodesource.com/setup_9.x | bash - && apt-get install -y nodejs
RUN npm i -g n
RUN npm i -g webpack-cli
RUN npm i -g gulp
RUN npm i -g yarn


COPY start.sh /
RUN ["chmod", "+x", "/start.sh"]

EXPOSE 80 443

ENTRYPOINT php-fpm7.2 && /start.sh && bash

VOLUME ["/var/www"]
