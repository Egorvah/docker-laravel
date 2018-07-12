#!/bin/bash

export ENV COMPOSER_ALLOW_SUPERUSER=1

# Output container info
echo -e "=== \tDocker container for laravel projects \t=== \n
- Nginx: \t$(nginx -v 2>&1 | head -n 1 | cut -d "/" -f 2 | cut -d " " -f 1) \n
- PHP: \t\t$(php --version | head -n 1 | cut -d " " -f 2 | cut -d "-" -f 1) \n
- Composer: \t$(composer -V | head -n 1 | cut -d " " -f 3) \n
- NodeJS: \t$(node -v | head -n 1 | cut -d "v" -f 2) \n"

# Add environment domain to nginx config
eval "sed -- \"s/{domain}/$DOMAIN/g\" /opt/laravel.conf > /etc/nginx/sites-enabled/laravel.conf && service nginx start"
