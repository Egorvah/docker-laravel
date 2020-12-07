FROM php:7.4-fpm-alpine AS laravel
MAINTAINER Egor Vakhrushev

ENV DOMAIN=laravel
ENV PHP_MEMORY_LIMIT 512M
ENV MAX_UPLOAD 50M
ENV PHP_MAX_FILE_UPLOAD 200
ENV PHP_MAX_POST 100M

RUN apk update && apk upgrade && \
    apk add --no-cache bash \
         openrc \
         openssl \
         git \
      	 vim \
      	 curl \
      	 wget \
      	 zip \
      	 unzip \
      	 libzip-dev \
      	 make \
      	 freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev 

# Install PHP modules

RUN apk add --no-cache postgresql-dev zlib-dev
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install gd zip opcache mysqli pdo_mysql pgsql pdo_pgsql

# Update PHP config
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
RUN sed -i -- "s/;clear_env = no/clear_env = no/g" /usr/local/etc/php-fpm.d/www.conf && \
	sed -i "s|listen = 9000|listen = /var/lib/php.sock|g" /usr/local/etc/php-fpm.d/zz-docker.conf && \
	sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /usr/local/etc/php/php.ini && \
    sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" /usr/local/etc/php/php.ini && \
    sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /usr/local/etc/php/php.ini && \
    sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /usr/local/etc/php/php.ini && \
	sed -i -- "s/;listen.allowed_clients = 127.0.0.1/listen.allowed_clients = 127.0.0.1/g" /usr/local/etc/php-fpm.d/www.conf && \
	sed -i -- "s/pm.start_servers = 2/pm.start_servers = 4/g" /usr/local/etc/php-fpm.d/www.conf && \
	sed -i -- "s/pm.min_spare_servers = 1/pm.min_spare_servers = 4/g" /usr/local/etc/php-fpm.d/www.conf && \
	sed -i -- "s/pm.max_spare_servers = 3/pm.max_spare_servers = 16/g" /usr/local/etc/php-fpm.d/www.conf && \
	sed -i -- "s/pm.max_requests = 500/pm.max_requests = 1000/g" /usr/local/etc/php-fpm.d/www.conf && \
	sed -i -- "s/pm.max_children = 5/pm.max_children = 128/g" /usr/local/etc/php-fpm.d/www.conf


# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Install Nginx
RUN apk add --no-cache nginx
RUN rc-update add nginx default
RUN mkdir -p /run/nginx/
RUN touch /run/nginx/nginx.pid

# Nginx config
COPY laravel.conf /opt

COPY start.sh /
RUN ["chmod", "+x", "/start.sh"]

EXPOSE 80 443

ENTRYPOINT php-fpm -D && /start.sh && bash

RUN rm -rf /var/www/html
WORKDIR /var/www

VOLUME ["/var/www"]