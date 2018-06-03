# based on Dockerfile from dtagdevsec/dionaea

FROM debian:stretch-slim
ENV DEBIAN_FRONTEND noninteractive

#
# Install dependencies and packages
#
RUN apt-get update -y && \
    apt-get upgrade -y && \
#
# some basic tools
#
    apt-get install -y --no-install-recommends \
      ca-certificates \
      git \
      procps && \
#
# reference: https://dionaea.readthedocs.io/en/0.7.0/installation.html
#
    apt-get install -y --no-install-recommends \
      autoconf \
      automake \
      build-essential \
      check \
      cython3 \
      libcap2-bin \
      libcurl4-openssl-dev \
      libemu-dev \
      libev-dev \
      libglib2.0-dev \
      libloudmouth1-dev \
      libnetfilter-queue-dev \
      libnl-3-dev \
      libpcap-dev \
      libtool \
      libssl-dev \
      libudns-dev \
      python3 \
      python3-dev \
      python3-bson \
      python3-yaml \
      ttf-liberation && \
#
# Get and install dionaea
#
    git clone https://github.com/dinotools/dionaea /root/dionaea/ && \
    cd /root/dionaea && \
#
# use autoreconf for now, cmake in 0.7.0 is not yet complete
# add --enable-static (idea from dtagdevsec)
#
    autoreconf -vi && \
    ./configure \
      --disable-werror \
      --prefix=/opt/dionaea \
      --with-python=/usr/bin/python3 \
      --with-cython-dir=/usr/bin \
      --enable-ev \
      --with-ev-include=/usr/include \
      --with-ev-lib=/usr/lib \
      --with-emu-lib=/usr/lib/libemu \
      --with-emu-include=/usr/include \
      --with-nl-include=/usr/include/libnl3 \
      --with-nl-lib=/usr/lib \
      --enable-static && \
    make && \
    make install && \
#
# Setup user and groups
#
    addgroup --gid 2000 dionaea && \
    adduser --system --no-create-home --shell /bin/bash --uid 2000 --disabled-password --disabled-login --gid 2000 dionaea && \
    setcap cap_net_bind_service=+ep /opt/dionaea/bin/dionaea && \
#
# Supply configs and set permissions
#
    chown -R dionaea:dionaea /opt/dionaea/var && \
#
# Setup runtime and clean up
#
    apt-get purge -y \
      autoconf \
      automake \
      build-essential \
      ca-certificates \
      check \
      cython3 \
      git \
      libcurl4-openssl-dev \
      libemu-dev \
      libev-dev \
      libglib2.0-dev \
      libloudmouth1-dev \
      libnetfilter-queue-dev \
      libnl-3-dev \
      libpcap-dev \
      libssl-dev \
      libtool \
      libudns-dev \
      python3 \
      python3-dev \   
      python3-bson \
      python3-yaml && \
#
    apt-get install -y \
      ca-certificates \
      python3 \
      python3-bson \
      python3-yaml \
      libcurl3 \
      libemu2 \
      libev4 \
      libglib2.0-0 \
      libnetfilter-queue1 \
      libnl-3-200 \
      libpcap0.8 \
      libpython3.5 \
      libudns0 && \
#
    apt-get autoremove --purge -y && \
    apt-get clean && \
    rm -rf /root/* /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Start dionaea
# USER dionaea:dionaea
CMD ["/opt/dionaea/bin/dionaea", "-u", "dionaea", "-g", "dionaea", "-c", "/opt/dionaea/etc/dionaea/dionaea.cfg"]
