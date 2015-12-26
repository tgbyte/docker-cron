FROM debian:8

RUN apt-get update && \
    apt-get install -y anacron

RUN mkdir /entrypoint.d

ADD ./entrypoint.sh /
CMD ["/entrypoint.sh"]

ONBUILD ADD ./cron/ /etc/cron/
