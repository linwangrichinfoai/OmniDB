FROM python:latest

LABEL maintainer="OmniDB team"

ARG OMNIDB_VERSION=3.0.3b

SHELL ["/bin/bash", "-c"]

USER root
RUN sed -i -e 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list
RUN addgroup --system omnidb \
    && adduser --system omnidb --ingroup omnidb \
    && apt-get update \
    && apt-get install libsasl2-dev python-dev libldap2-dev libssl-dev vim -y

USER omnidb:omnidb
ENV HOME /home/omnidb
WORKDIR ${HOME}

COPY OmniDB-3.0.3b.zip 3.0.3b.zip

RUN unzip ${OMNIDB_VERSION}.zip \
    && mv OmniDB-${OMNIDB_VERSION} OmniDB

WORKDIR ${HOME}/OmniDB

RUN pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple

WORKDIR ${HOME}/OmniDB/OmniDB

RUN sed -i "s/LISTENING_ADDRESS    = '127.0.0.1'/LISTENING_ADDRESS    = '0.0.0.0'/g" config.py \
    && python omnidb-server.py --init \
    && python omnidb-server.py --dropuser=admin

USER root
RUN apt-get install libaio1
USER omnidb:omnidb

EXPOSE 8000

CMD python omnidb-server.py