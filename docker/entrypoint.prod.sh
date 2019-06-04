#!/bin/bash
set -eo pipefail

if [ ! -f storage/.initialized ]; then
    touch storage/.initialized;
    # laravel storage folder structure (v5.4+)
    mkdir -p storage/{app/public,framework/{cache,sessions,testing,views},logs}

    chown -R nginx:nginx storage
    chmod -R ug+rwx storage bootstrap/cache
fi

su-exec nginx:nginx php artisan config:cache && php artisan view:clear

/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf

exit 0
