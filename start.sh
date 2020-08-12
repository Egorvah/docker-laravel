#!/bin/bash

export ENV COMPOSER_ALLOW_SUPERUSER=1

# Output container info
echo -e "=== \tDocker container for laravel projects \t=== \n
- Nginx: \t$(nginx -v 2>&1 | head -n 1 | cut -d "/" -f 2) \n
- PHP: \t\t$(php --version | head -n 1 | cut -d " " -f 2) \n
- Composer: \t$(composer -V | head -n 1 | cut -d " " -f 3)"


test -x /var/www/helper.sh && cd /var/www && ./helper.sh
test -f /var/www/crontab && cp /var/www/crontab /var/spool/cron/crontabs/nobody && crond -L /var/log/crond.log

chmod 777 /var/lib/php.sock