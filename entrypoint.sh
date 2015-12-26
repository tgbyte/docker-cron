#!/bin/bash

for f in /entrypoint.d/*.sh; do
   . $f
done

exec cron -f -L 15
