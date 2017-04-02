FROM armhf/debian:jessie

ENV DEBIAN_FRONTEND=noninteractive \
    DUMBINIT_VERSION=1.2.0

RUN set -x \
    && apt-get update -qq \
    && apt-get -o Apt::Install-Recommends=0 install -y -q \
         ca-certificates \
         curl \
         wget \
    && sed -i "s/httpredir.debian.org/`curl -s -D - http://httpredir.debian.org/demo/debian/ | awk '/^Link:/ { print $2 }' | sed -e 's@<http://\(.*\)/debian/>;@\1@g'`/" /etc/apt/sources.list \
    && apt-get update -qq \
    && apt-get -o Apt::Install-Recommends=0 install -y -q \
         bcron \
         build-essential \
         daemontools \
         supervisor \
         ucspi-unix \
    && echo $DUMBINIT_VERSION \
    && (curl -L https://github.com/Yelp/dumb-init/archive/v${DUMBINIT_VERSION}.tar.gz | tar -C /tmp -xzf -) \
    && ls -al /tmp \
    && gcc -std=gnu99 -s -Wall -Werror -O3 -o /usr/local/sbin/dumb-init /tmp/dumb-init-*/dumb-init.c \
    && rm -rf /tmp/dumb-init-* \
    && apt-get remove -y --purge \
         build-essential \
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

ENTRYPOINT ["/usr/local/sbin/dumb-init"]
CMD ["/entrypoint.sh"]

ONBUILD ADD ./cron/ /etc/
