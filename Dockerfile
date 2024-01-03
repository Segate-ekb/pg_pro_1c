FROM ubuntu:22.04

ARG SERVER_VERSION=15
ARG SERVER_VERSION_DOT
ARG KEYS_DOT


RUN ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime 

ENV TZ Europe/Moscow

ENV DEBIAN_FRONTEND noninteractive
ENV TERM xterm

RUN apt-get -qq update \
&& apt-get -qq install --yes --no-install-recommends ca-certificates wget locales apt-utils\
&& apt-get -qq install --yes --no-install-recommends mc htop sudo

RUN localedef --inputfile en_US --force --charmap UTF-8 --alias-file /usr/share/locale/locale.alias en_US.UTF-8

RUN localedef --inputfile ru_RU --force --charmap UTF-8 --alias-file /usr/share/locale/locale.alias ru_RU.UTF-8

ENV LANG ru_RU.UTF-8

ARG GOSU_VERSION=1.16

RUN wget --quiet -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
    && chmod +x /usr/local/bin/gosu


ARG PGPRO=/opt/pgpro
ENV PATH $PGPRO/1c-${SERVER_VERSION}/bin:$PATH
ENV LD_LIBRARY_PATH $PGPRO/1c-${SERVER_VERSION}/lib
ENV PGDATA $PGPRO/data
ENV PGUSER postgres

RUN wget --quiet http://repo.postgrespro.ru/1c-$SERVER_VERSION/keys/pgpro-repo-add.sh -O /tmp/pgpro-repo-add.sh \
    && sh /tmp/pgpro-repo-add.sh

RUN apt-get -y install postgrespro-1c-$SERVER_VERSION-server \
    && apt-get -y install postgrespro-1c-$SERVER_VERSION-contrib


RUN apt install -y perl 

RUN wget --quiet -O /usr/bin/pgcompacttable "https://raw.githubusercontent.com/dataegret/pgcompacttable/master/bin/pgcompacttable" \
    && chmod +x /usr/bin/pgcompacttable \
    && wget --quiet -O /tmp/pgcenter_0.9.2_linux_amd64.deb https://github.com/lesovsky/pgcenter/releases/download/v0.9.2/pgcenter_0.9.2_linux_amd64.deb \
    && apt install -y  /tmp/pgcenter_0.9.2_linux_amd64.deb


RUN mkdir --parent /var/run/postgresql \
  && chown --recursive postgres:postgres /var/run/postgresql \
  && chmod g+s /var/run/postgresql \
  && mkdir --parent "$PGDATA" \
  && chown --recursive postgres:postgres "$PGDATA" \
  && mkdir /docker-entrypoint-initdb.d \
  && mkdir /docker-entrypoint-startdb.d

COPY container/docker-entrypoint.sh /
COPY container/init-temp.sh /docker-entrypoint-startdb.d
COPY container/init-getconfig.sh /docker-entrypoint-initdb.d

RUN chmod 755 /docker-entrypoint.sh \
  && chmod +x /docker-entrypoint.sh


RUN  mkdir --parent "$PGPRO/1C/data" \
  && mkdir --parent "$PGPRO/1C/index" \
  && ln -s /tmp/pgpro/temp/ /opt/pgpro/1C \
  && chown --recursive postgres:postgres "$PGPRO/1C" \
  && ln -s $PGDATA/pg_log /var/log/pgpro

ENTRYPOINT ["/docker-entrypoint.sh"]

VOLUME $PGDATA
VOLUME $PGPRO/1C/data
VOLUME $PGPRO/1C/index

EXPOSE 5432

CMD ["postgres"]
