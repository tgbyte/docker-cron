#!/bin/bash

chown -R cron.nogroup /var/spool/cron

for f in /entrypoint.d/*.sh; do
   . $f
done

exec supervisord -c /etc/supervisor/conf.d/supervisord.conf
