#!/bin/bash
set -eo pipefail

su-exec nginx:nginx php artisan config:cache

/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf

exit 0
