# Databasement for Railway: the official image, pinned by version and digest,
# plus a small start script that creates the admin before the web server opens.
FROM davidcrty/databasement:1.10.12@sha256:ecf067e3e4c46d5b418553434e3eba48914205040098d9ae511e726b3edb48c9

# One container: web server, queue worker and scheduler, SQLite on the /data volume.
ENV DB_CONNECTION=sqlite \
    DB_DATABASE=/data/database.sqlite \
    ENABLE_QUEUE_WORKER=true \
    ENABLE_SCHEDULER=true \
    ENABLE_WEB_SERVER=true \
    APP_ENV=production \
    APP_DEBUG=false

COPY railway-start.sh railway-bootstrap.php /usr/local/bin/
RUN chmod 755 /usr/local/bin/railway-start.sh && chmod 644 /usr/local/bin/railway-bootstrap.php

EXPOSE 2226
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD ["/usr/local/bin/start.sh"]
