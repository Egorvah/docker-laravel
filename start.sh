#!/bin/bash

# Output container info
echo -e "=== \tDocker container for laravel projects \t=== \n
- Nginx: \t$(nginx -v 2>&1 | head -n 1 | cut -d "/" -f 2) \n
- PHP: \t\t$(php --version | head -n 1 | cut -d " " -f 2) \n
- NodeJS: \t$(node -v) \n
- Composer: \t$(composer -V | head -n 1 | cut -d " " -f 3)"

# Add environment domain to nginx config
eval "sed -- \"s/{domain}/$DOMAIN/g\" /opt/laravel.conf > /etc/nginx/sites-enabled/laravel.conf && service nginx start"
