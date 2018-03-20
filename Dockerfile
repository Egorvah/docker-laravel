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
			php7.1-fpm \
			php7.1-cli \
			php7.1-common \
			php7.1-mbstring \
			php7.1-gd \
			php7.1-intl \
			php7.1-xml \
			php7.1-mysql \
			php7.1-pgsql \
			php7.1-opcache \
			php7.1-zip \
			php7.1-dev \
			php7.1-curl \
			php7.1-sqlite3 \
			php7.1-mcrypt
RUN mkdir -p /run/php
RUN sed -i -- "s/;clear_env = no/clear_env = no/g" /etc/php/7.1/fpm/pool.d/www.conf

# Install composer
RUN cd /opt && curl -sS https://getcomposer.org/installer -o composer-setup.php && php composer-setup.php --install-dir=/usr/bin --filename=composer && rm composer-setup.php

# Install nodejs
RUN cd /opt && curl -sL https://deb.nodesource.com/setup_9.x | bash - && apt-get install -y nodejs
RUN npm i -g n
RUN npm i -g webpack
RUN npm i -g gulp
RUN npm i -g yarn


COPY start.sh /
RUN ["chmod", "+x", "/start.sh"]

EXPOSE 80 443

ENTRYPOINT php-fpm7.1 && /start.sh && bash

VOLUME ["/var/www"]
