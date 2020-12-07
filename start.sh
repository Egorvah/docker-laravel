#!/bin/bash

export ENV COMPOSER_ALLOW_SUPERUSER=1

# Output container info
echo -e "=== \tDocker container for laravel projects \t=== \n
- Nginx: \t$(nginx -v 2>&1 | head -n 1 | cut -d "/" -f 2) \n
- PHP: \t\t$(php --version | head -n 1 | cut -d " " -f 2) \n
- Composer: \t$(composer -V | head -n 1 | cut -d " " -f 3)"

chmod 777 /var/lib/php.sock

# Add environment domain to nginx config
eval "sed -- \"s/{domain}/$DOMAIN/g\" /opt/laravel.conf > /etc/nginx/conf.d/laravel.conf && nginx"