FROM debian:8

RUN apt-get update && \
    apt-get -o Apt::Install-Recommends=0 install -y bcron daemontools supervisor ucspi-unix && \
    rm -rf /var/lib/apt/lists/*

RUN adduser --system --no-create-home --home /var/spool/cron cron && \
    touch /etc/crontab && \
    mkdir /etc/cron.d && \
    mkdir -p /var/spool/cron/crontabs && \
    mkdir -p /var/spool/cron/tmp

ADD ./etc/bcron /etc/bcron

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir /etc/supervisor/conf.d/supervisord.conf.d

RUN mkdir /entrypoint.d
ADD /entrypoint.d/*.sh /entrypoint.d/
ADD ./entrypoint.sh /
CMD ["/entrypoint.sh"]

ONBUILD ADD ./cron/ /etc/
