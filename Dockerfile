FROM amd64/ubuntu:18.04 as qemu

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
  && apt-get update -qq \
  && apt-get install -qq -y qemu-user-static

FROM debian:10

COPY --from=qemu /usr/bin/qemu-arm-static /usr/bin

ENV DEBIAN_FRONTEND=noninteractive
RUN set -x \
    && sed -i "s/httpredir.debian.org/`curl -s -D - http://httpredir.debian.org/demo/debian/ | awk '/^Link:/ { print $2 }' | sed -e 's@<http://\(.*\)/debian/>;@\1@g'`/" /etc/apt/sources.list \
    && apt-get update -qq \
    && apt-get -o Apt::Install-Recommends=0 install -y -q \
         bcron \
         ca-certificates \
         dumb-init \
         daemontools \
         parallel \
         supervisor \
         ucspi-unix \
    && rm -rf /var/lib/apt/lists/* \
    && adduser --system --no-create-home --home /var/spool/cron cron \
    && touch /etc/crontab \
    && mkdir -p /etc/cron.d \
    && mkdir -p /var/spool/cron/crontabs \
    && mkdir -p /var/spool/cron/tmp \
    && mkdir -p /entrypoint.d /log /etc/supervisor/conf.d/supervisord.conf.d \
    && rm /etc/cron.d/* /etc/cron.daily/*

ADD ./etc/bcron /etc/bcron

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

ADD entrypoint.d/*.sh /entrypoint.d/
ADD entrypoint.sh /bin/

ENTRYPOINT ["/usr/bin/dumb-init"]
CMD ["/bin/entrypoint.sh"]

ONBUILD ADD ./cron/ /etc/
