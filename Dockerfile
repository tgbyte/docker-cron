FROM amd64/ubuntu:18.04 as qemu

ENV DEBIAN_FRONTEND=noninteractive

RUN set -x \
  && apt-get update -qq \
  && apt-get install -qq -y qemu-user-static

FROM debian:buster

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
         supervisor \
         ucspi-unix \
    && rm -rf /var/lib/apt/lists/* \
    && adduser --system --no-create-home --home /var/spool/cron cron \
    && touch /etc/crontab \
    && mkdir /etc/cron.d \
    && mkdir -p /var/spool/cron/crontabs \
    && mkdir -p /var/spool/cron/tmp

ADD ./etc/bcron /etc/bcron

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir /etc/supervisor/conf.d/supervisord.conf.d

RUN mkdir /entrypoint.d
ADD /entrypoint.d/*.sh /entrypoint.d/
ADD ./entrypoint.sh /

ENTRYPOINT ["/usr/bin/dumb-init"]
CMD ["/entrypoint.sh"]

ONBUILD ADD ./cron/ /etc/
