FROM debian:latest

MAINTAINER Stefan Haller <s.haller@agdsn.de>

# CoreOS uses this gid for the docker group
# can be overridden as this is a build arg
ARG docker_gid=233

RUN sed -i 's|http://deb.debian.org/|http://ftp.agdsn.de/|' /etc/apt/sources.list && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        git \
        locales \
        python3 \
        python3-pip && \
    apt-get clean && \
    rm -fr /var/lib/apt/lists/* && \
    echo 'en_US.UTF-8 UTF-8' >/etc/locale.gen && \
    locale-gen

ENV LANG=en_US.UTF-8

RUN groupadd -g $docker_gid docker && \
    useradd -ms /bin/bash user && \
    gpasswd --add user docker

ADD . /home/user/

RUN chown -R user:user /home/user && \
    cd /home/user && \
    runuser -u user -- bash -c 'git clone https://github.com/jplana/python-etcd.git && cd python-etcd && pip3 install --user .' && \
    runuser -u user -- pip3 install --user -r requirements.py

USER user
WORKDIR /home/user

CMD ["/home/user/run.py"]

# vim: set ts=4 sts=4 sw=4 et:
