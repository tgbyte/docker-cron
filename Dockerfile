FROM debian:8

ENV DEBIAN_FRONTEND=noninteractive \
    DUMBINIT_VERSION=1.2.0 \
    DUMBINIT_SHA256SUM=81231da1cd074fdc81af62789fead8641ef3f24b6b07366a1c34e5b059faf363

RUN set -x \
    && apt-get update -qq \
    && apt-get -o Apt::Install-Recommends=0 install -y -q \
         ca-certificates \
         curl \
         wget \
    && sed -i "s/httpredir.debian.org/`curl -s -D - http://httpredir.debian.org/demo/debian/ | awk '/^Link:/ { print $2 }' | sed -e 's@<http://\(.*\)/debian/>;@\1@g'`/" /etc/apt/sources.list \
    && apt-get -o Apt::Install-Recommends=0 install -y -q
         bcron \
         daemontools \
         supervisor \
         ucspi-unix \
    && wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v${DUMBINIT_VERSION}/dumb-init_${DUMBINIT_VERSION}_amd64 \
    && echo "${DUMBINIT_SHA256SUM}  /usr/local/bin/dumb-init" > /tmp/SHA256SUM \
    && sha256sum -c /tmp/SHA256SUM \
    && rm /tmp/SHA256SUM \
    && chmod +x /usr/local/bin/dumb-init \
    && apt-get remove -y --purge \
         curl \
         wget \
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

ENTRYPOINT ["/usr/local/bin/dumb-init"]
CMD ["/entrypoint.sh"]

ONBUILD ADD ./cron/ /etc/
