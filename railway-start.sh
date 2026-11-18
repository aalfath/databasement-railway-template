#!/bin/sh
# Railway wrapper for Databasement. Runs as root, then hands over to the image's
# own entrypoint and start script (supervisord: FrankenPHP, queue worker, scheduler).
set -e

: "${APP_KEY:?APP_KEY must be set (the template generates it)}"

# Laravel's AES-256 key must be 32 bytes or "base64:<32 bytes>". A generated
# secret of any other length is turned into a stable key (SHA-256 of it), so the
# same variable always gives the same key across redeploys.
case "$APP_KEY" in
  base64:*) ;;
  *)
    if [ "$(printf %s "$APP_KEY" | wc -c)" -ne 32 ]; then
      APP_KEY="base64:$(php -r 'echo base64_encode(hash("sha256", getenv("APP_KEY"), true));')"
      export APP_KEY
    fi
    ;;
esac

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
