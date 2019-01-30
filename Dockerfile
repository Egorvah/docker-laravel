FROM php:7.2-fpm-alpine3.7 AS laravel
MAINTAINER Egor Vakhrushev

ENV DOMAIN=laravel

RUN apk update && apk upgrade && \
    apk add --no-cache bash \
         openrc \
         openssl \
         git \
      	 vim \
      	 curl \
      	 wget

# Install Nginx
RUN apk add --no-cache nginx
RUN rc-update add nginx default
RUN mkdir -p /run/nginx/
RUN touch /run/nginx/nginx.pid
RUN mkdir -p /opt
COPY laravel.conf /opt

# Install PHP modules

RUN apk add --no-cache postgresql-dev zlib-dev
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install opcache  mysqli pdo_mysql pgsql pdo_pgsql zip

# Update PHP config
RUN sed -i -- "s/;clear_env = no/clear_env = no/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i -- "s/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i -- "s/pm.start_servers = 2/pm.start_servers = 4/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i -- "s/pm.min_spare_servers = 1/pm.min_spare_servers = 4/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i -- "s/pm.max_spare_servers = 3/pm.max_spare_servers = 16/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i -- "s/pm.max_requests = 500/pm.max_requests = 1000/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i -- "s/pm.max_children = 5/pm.max_children = 128/g" /usr/local/etc/php-fpm.d/www.conf


# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN php -m

COPY start.sh /
RUN ["chmod", "+x", "/start.sh"]

EXPOSE 80 443

ENTRYPOINT php-fpm -D && /start.sh && bash

VOLUME ["/var/www"]
