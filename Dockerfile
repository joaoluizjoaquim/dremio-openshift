FROM openjdk:8

LABEL org.label-schema.name='dremio/dremio-oss'
LABEL org.label-schema.description='Dremio OSS.'

ARG DOWNLOAD_URL=https://download.dremio.com/community-server/3.3.1-201907291852280797-df23756/dremio-community-3.3.1-201907291852280797-df23756.tar.gz
ARG CONTAINER_ROLE=coordinator
ARG USER=1000121000

ENV DREMIO_HOME="/opt/dremio" \
    DREMIO_PID_DIR="/var/run/dremio" \
    SERVER_GC_OPTS="-XX:+PrintGCDetails -XX:+PrintGCDateStamps" \
    ZOOKEEPER_URL=zoo1:2181,zoo2:2181,zoo3:2181

RUN \
  mkdir -p                      /opt/dremio \
  && chown -R ${USER}           /opt/dremio \
  && chmod -R ug+rwx            /opt/dremio \
  \
  && mkdir -p                   /var/lib/dremio \
  && chown -R ${USER}           /var/lib/dremio \
  && chmod -R ug+rwx            /var/lib/dremio \
  \
  && mkdir -p                   /var/run/dremio \
  && chown -R ${USER}           /var/run/dremio \
  && chmod -R ug+rwx            /var/run/dremio \
  \
  && mkdir -p                   /var/log/dremio \
  && chown -R ${USER}           /var/log/dremio \
  && chmod -R ug+rwx            /var/log/dremio \
  \
  && mkdir -p                   /opt/dremio/data \
  && chown -R ${USER}           /opt/dremio/data \
  && chmod -R ug+rwx            /opt/dremio/data \
  \
  && wget -q "${DOWNLOAD_URL}" -O dremio.tar.gz \
  && tar vxfz dremio.tar.gz -C /opt/dremio --strip-components=1 \
  && rm -rf dremio.tar.gz

ADD confs/dremio-${CONTAINER_ROLE}.conf /opt/dremio/conf/dremio.conf
ADD confs/dremio-env /opt/dremio/conf/dremio-env

RUN  \
  chown -R ${USER}              /opt/dremio \
  && chmod -R ug+rwx            /opt/dremio

EXPOSE 9047/tcp
EXPOSE 31010/tcp
EXPOSE 45678/tcp

USER ${USER}
WORKDIR /opt/dremio
ENTRYPOINT ["bin/dremio", "start-fg"]
