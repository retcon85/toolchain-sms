ARG PYTHON_VERSION="3.13"
ARG BASE_VARIANT="bookworm"

# ------------------------------------------------- #
# base installs python3 for general purpose tooling #
# ------------------------------------------------- #

FROM python:${PYTHON_VERSION}-${BASE_VARIANT} AS smstk-base

# ----------------------------- #
# common tools                  #
# ----------------------------- #

#!TODO: install cmake on base (generally consolidate tools)!
RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    gcc \
    ca-certificates \
    clang \
    curl \
    libffi-dev \
    libreadline-dev \
    libboost-all-dev \
    tcl-dev \
    graphviz \
    xdot \
    git \
 && apt-get autoclean && apt-get clean && apt-get -y autoremove \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists

FROM smstk-base AS smstk-builder-base

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    bison \
    flex \
    texinfo \
 && apt-get autoclean && apt-get clean && apt-get -y autoremove \
 && rm -rf /var/lib/apt/lists

# ----------------------------- #
# wla-dx assembler              #
# ----------------------------- #

FROM smstk-base AS wla-dx-builder

RUN apt-get update && apt-get install -y \
    ca-certificates \
    gcc \
    g++ \
    nasm \
    make \
    unzip \
    cmake \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# WLA-DX
    # 10.5
RUN git clone --branch v10.5 --single-branch https://github.com/vhelin/wla-dx.git && \
    cd wla-dx && \
    mkdir build && cd build && \
    cmake .. && \
    cmake --build . --config Release && \
    cmake -DCMAKE_INSTALL_PREFIX=/tmp/wla-dx/wla-dx-10.5 -P cmake_install.cmake \
    # 10.6
    && git clone --branch v10.6 --single-branch https://github.com/vhelin/wla-dx.git && \
    cd wla-dx && \
    mkdir build && cd build && \
    cmake .. && \
    cmake --build . --config Release && \
    cmake -DCMAKE_INSTALL_PREFIX=/tmp/wla-dx/wla-dx-10.6 -P cmake_install.cmake

# ----------------------------- #
# devkitSMS                     #
# ----------------------------- #
FROM smstk-builder-base AS sdcc-builder

WORKDIR /tmp

# SDCC
    # 4.3
RUN curl -o sdcc-src-4.3.0.tar.bz2 -L "https://downloads.sourceforge.net/project/sdcc/sdcc/4.3.0/sdcc-src-4.3.0.tar.bz2" \
    && tar -xvjf sdcc-src-4.3.0.tar.bz2 \
    && cd sdcc-4.3.0 \
    && ./configure --disable-pic14-port --disable-pic16-port \
    && make -j 4 \
    && make install prefix=/tmp/sdcc/sdcc-4.3 \
    # 4.4
    && curl -o sdcc-src-4.4.0.tar.bz2 -L "https://downloads.sourceforge.net/project/sdcc/sdcc/4.4.0/sdcc-src-4.4.0.tar.bz2" \
    && tar -xjf sdcc-src-4.4.0.tar.bz2 \
    && cd sdcc-4.4.0 \
    && ./configure --disable-pic14-port --disable-pic16-port \
    && make -j 4 \
    && make install prefix=/tmp/sdcc/sdcc-4.4 \
    # Need boost update for SDCC 4.5
    && curl -o boost_1_87_0 -L "https://archives.boost.io/release/1.87.0/source/boost_1_87_0.tar.bz2" \
    && tar -xjf boost_1_87_0 \
    && cd boost_1_87_0 \
    && ./bootstrap.sh \
    && ./b2 install \
    # 4.5
    && curl -o sdcc-src-4.5.0.tar.bz2 -L "https://downloads.sourceforge.net/project/sdcc/sdcc/4.5.0/sdcc-src-4.5.0.tar.bz2" \
    && tar -xjf sdcc-src-4.5.0.tar.bz2 \
    && cd sdcc-4.5.0 \
    && ./configure --disable-pic14-port --disable-pic16-port \
    && make -j 4 \
    && make install prefix=/tmp/sdcc/sdcc-4.5

FROM sdcc-builder AS devkitsms-builder

WORKDIR /tmp

# ephemeral step, to allow building of devkitsms components - using SDCC 4.3
COPY --from=sdcc-builder /tmp/sdcc/sdcc-4.3 /usr/local/
RUN mkdir -p /tmp/devkitsms/bin \
    && mkdir -p /tmp/devkitsms/lib \
    && mkdir -p /tmp/devkitsms/include \
    && git clone --branch master --single-branch https://github.com/sverx/devkitSMS.git \
    && cd devkitSMS \
    && git checkout 1d65541a11800aa688d8649c4a393282717e2e5f \
    && cd ihx2sms \
    && mkdir build \
    && gcc -o build/ihx2sms src/ihx2sms.c \
    && cp build/ihx2sms /tmp/devkitsms/bin \
    && cd ../makesms \
    && mkdir build \
    && gcc -o build/makesms src/makesms.c \
    && cp build/makesms /tmp/devkitsms/bin \
    && cd ../folder2c \
    && mkdir build \
    && gcc -o build/folder2c src/folder2c.c \
    && cp build/folder2c /tmp/devkitsms/bin \
    && cd .. \
    && cp assets2banks/src/assets2banks.py /tmp/devkitsms/bin/assets2banks \
    && chmod +x /tmp/devkitsms/bin/assets2banks \
    && mkdir -p /tmp/devkitsms/lib \
    && mkdir -p /tmp/devkitsms/include \
    && cp crt0/crt0_sms.rel /tmp/devkitsms/lib \
    && cp SMSlib/SMSlib.lib /tmp/devkitsms/lib \
    && cp SMSlib/SMSlib_GG.lib /tmp/devkitsms/lib \
    && cp SMSlib/src/SMSlib.h /tmp/devkitsms/include \
    && cp SMSlib/src/peep-rules.txt /tmp/devkitsms/lib \
    && cp PSGlib/PSGlib.lib /tmp/devkitsms/lib \
    && cp PSGlib/src/PSGlib.h /tmp/devkitsms/include


# ----------------------------- #
# utils                         #
# ----------------------------- #
FROM smstk-builder-base AS utils-builder
WORKDIR /tmp
RUN mkdir -p local/bin

# img2tiles python script
RUN git clone --branch v0.3 --single-branch https://github.com/retcon85/retcon-util-sms.git
RUN cp retcon-util-sms/img2tiles.py local/bin/img2tiles \
    && chmod +x local/bin/img2tiles

# psglib tools
RUN git clone --branch master --single-branch https://github.com/sverx/PSGlib.git \
    && cd PSGlib \
    && git checkout 88346ee7620b750564008cffb54728da3ddc114e \
    && cd tools/src \
    && gcc -o /tmp/local/bin/psgcomp psgcomp.c \
    && gcc -o /tmp/local/bin/psgdecomp psgdecomp.c \
    && gcc -o /tmp/local/bin/vgm2psg vgm2psg.c -lz

ARG TARGETOS
ARG TARGETARCH
# retcon-util-audio
RUN curl -o retcon-audio-0.0.5-${TARGETOS}-${TARGETARCH} -L "https://github.com/retcon85/retcon-util-audio/releases/download/0.0.5/retcon-audio-0.0.5-${TARGETOS}-${TARGETARCH}.bz2" \
    && tar -xvjf retcon-audio-0.0.5-${TARGETOS}-${TARGETARCH} \
    && mv ./retcon-audio local/bin

# ----------------------------- #
# final image compilation       #
# ----------------------------- #

FROM smstk-base

# ----------------------------- #
# add more general tools        #
# ----------------------------- #

RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    xxd \
    nano

# copy sdcc & devkitsms
COPY --from=devkitsms-builder /tmp/devkitsms/ /opt/devkitsms/
COPY --from=devkitsms-builder /tmp/sdcc/ /opt/
# symlink default SDCC version (4.3)
RUN ln -s /opt/sdcc-4.3 /opt/sdcc
# add to path
ENV PATH=/opt/devkitsms/bin:/opt/sdcc/bin:$PATH

# copy wla-dx
COPY --from=wla-dx-builder /tmp/wla-dx /opt/
# symlink default WLA-DX version (10.6)
RUN ln -s /opt/wla-dx-10.6 /opt/wla-dx
# add to path
ENV PATH=/opt/wla-dx/bin:$PATH

# copy retcon-utils
COPY --from=utils-builder /tmp/local/bin/* /usr/local/bin/

# copy misc docker image utils
COPY ./export-h.sh /usr/local/bin/export-h
RUN chmod +x /usr/local/bin/export-h
COPY ./use-sdcc.sh /usr/local/bin/use-sdcc
RUN chmod +x /usr/local/bin/use-sdcc
COPY ./use-wla-dx.sh /usr/local/bin/use-wla-dx
RUN chmod +x /usr/local/bin/use-wla-dx
COPY ./zsh-function /home/retcon/

WORKDIR /home/retcon
ENV HOME=/home/retcon
USER root
ENTRYPOINT ["/bin/bash", "-c"]
