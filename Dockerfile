#
# Copyright (C) 2017 Dremio Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

FROM openjdk:8-jdk as run

LABEL org.label-schema.name='dremio/dremio-oss'
LABEL org.label-schema.description='Dremio OSS.'

ARG DOWNLOAD_URL=https://download.dremio.com/community-server/3.3.1-201907291852280797-df23756/dremio-community-3.3.1-201907291852280797-df23756.tar.gz
ARG CONTAINER_ROLE=coordinator
ARG USER=dremio
ARG USER_ID=1000120111
ARG GROUP=dremio

ENV DREMIO_HOME /opt/dremio \
    DREMIO_PID_DIR /var/run/dremio \
    SERVER_GC_OPTS="-XX:+PrintGCDetails -XX:+PrintGCDateStamps"

RUN groupadd --gid 1000 ${GROUP} \
  && useradd --uid ${USER_ID} --gid 1000 ${USER}

RUN \
  mkdir -p                      /opt/dremio \
  && chown -R ${USER}:${GROUP}  /opt/dremio \
  && chmod -R ug+rwx            /opt/dremio \
  \
  && mkdir -p                   /var/lib/dremio \
  && chown -R ${USER}:${GROUP}  /var/lib/dremio \
  && chmod -R ug+rwx            /var/lib/dremio \
  \
  && mkdir -p                   /var/run/dremio \
  && chown -R ${USER}:${GROUP}  /var/run/dremio \
  && chmod -R ug+rwx            /var/run/dremio \
  \
  && mkdir -p                   /var/log/dremio \
  && chown -R ${USER}:${GROUP}  /var/log/dremio \
  && chmod -R ug+rwx            /var/log/dremio \
  \
  && mkdir -p                   /opt/dremio/data \
  && chown -R ${USER}:${GROUP}  /opt/dremio/data \
  && chmod -R ug+rwx            /opt/dremio/data \
  \
  && wget -q "${DOWNLOAD_URL}" -O dremio.tar.gz \
  && tar vxfz dremio.tar.gz -C /opt/dremio --strip-components=1 \
  && rm -rf dremio.tar.gz

COPY confs/dremio-${CONTAINER_ROLE}.conf /opt/dremio/conf/dremio.conf
COPY confs/dremio-env /opt/dremio/conf/dremio-env

EXPOSE 9047/tcp
EXPOSE 31010/tcp
EXPOSE 45678/tcp

USER ${USER}
WORKDIR /opt/dremio
ENTRYPOINT ["bin/dremio", "start-fg"]