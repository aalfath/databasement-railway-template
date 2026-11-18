#!/bin/sh
# Railway wrapper for Databasement. Runs as root, then hands over to the image's
# own entrypoint and start script (supervisord: FrankenPHP, queue worker, scheduler).
set -e

: "${APP_KEY:?APP_KEY must be set (the template generates it)}"

# FrankenPHP listens on the address in SERVER_NAME; Railway routes to PORT.
export SERVER_NAME=":${PORT:-2226}"

# Railway mounts the volume owned by root; the app runs as the "application" user.
mkdir -p /data/backups
chown -R application:application /data

# Migrate and create the first admin before the web server starts, so the
# public /register page (first visitor becomes super admin) is never open.
cd /app
su -m -s /bin/sh application -c 'php artisan migrate --force --no-interaction && php /usr/local/bin/railway-bootstrap.php'

exec /usr/local/bin/docker-entrypoint.sh "$@"
