FROM alpine:3.7 AS laravel
MAINTAINER Egor Vakhrushev

ENV DOMAIN=laravel

ADD https://php.codecasts.rocks/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

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

# Install PHP
RUN apk --update add ca-certificates \
    && echo "@edge-main http://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories \
    && echo "@edge-community http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories \
    && echo "@cast https://php.codecasts.rocks/v3.7/php-7.2" >> /etc/apk/repositories \
    && apk add --update --no-cache \
        php7-common@cast \
        php7-intl@cast \
        php7-calendar@cast \
        php7-tidy@cast \
        php7-session@cast \
        php7-sockets@cast \
        php7-sodium@cast \
        php7-soap@cast \
        php7-openssl@cast \
        php7-gmp@cast \
        php7-pdo_odbc@cast \
        php7-json@cast \
        php7-dom@cast \
        php7-pdo@cast \
        php7-zip@cast \
        php7-mysqli@cast \
        php7-sqlite3@cast \
        php7-pdo_pgsql@cast \
        php7-bcmath@cast \
        php7-gd@cast \
        php7-odbc@cast \
        php7-pdo_mysql@cast \
        php7-pdo_sqlite@cast \
        php7-gettext@cast \
        php7-xmlreader@cast \
        php7-xmlwriter@cast \
        php7-xml@cast \
        php7-bz2@cast \
        php7-iconv@cast \
        php7-pdo_dblib@cast \
        php7-curl@cast \
        php7-ctype@cast \
        php7-pcntl@cast \
        php7-posix@cast \
        php7-phar@cast \
        php7-opcache@cast \
        php7-mbstring@cast \
        php7-zlib@cast \
        php7-tokenizer@cast \
        php7-fpm@cast \
        php7-xdebug \
        php7@cast \

       && ln -s /usr/bin/php7 /usr/bin/php \
       && rm -rf /var/cache/apk/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN php -m

COPY start.sh /
RUN ["chmod", "+x", "/start.sh"]

EXPOSE 80 443

ENTRYPOINT php-fpm7 && /start.sh && bash

VOLUME ["/var/www"]