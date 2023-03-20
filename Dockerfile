# ------------------------------------------------- #
# base installs python3 for general purpose tooling #
# ------------------------------------------------- #

FROM python:3.11.0 AS smstk-base

# ----------------------------- #
# common tools                  #
# ----------------------------- #

#!TODO: install cmake on base (generally consolidate tools)!
RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
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

RUN git clone --branch v10.3 --single-branch https://github.com/vhelin/wla-dx.git && \
    cd wla-dx && \
    mkdir build && cd build && \
    cmake .. && \
    cmake --build . --config Release && \
    cmake -DCMAKE_INSTALL_PREFIX=/tmp/wla-dx -P cmake_install.cmake

# ----------------------------- #
# devkitSMS                     #
# ----------------------------- #
FROM smstk-builder-base AS devkitsms-builder

WORKDIR /tmp
RUN curl -o sdcc-src-20230127-13827.tar.bz2 -L "https://downloads.sourceforge.net/project/sdcc/snapshot_builds/sdcc-src/sdcc-src-20230127-13827.tar.bz2" \
    && tar -xvjf sdcc-src-20230127-13827.tar.bz2 \
    && mv sdcc sdcc-snapshot \
    && cd sdcc-snapshot \
    && ./configure --disable-pic14-port --disable-pic16-port \
    && make -j 4
RUN cd sdcc-snapshot \
    && make install prefix=/tmp/sdcc
RUN git clone --branch master --single-branch https://github.com/sverx/devkitSMS.git \
    && cd devkitSMS \
    && git checkout 86784470529f2c87428b5126e2be25e2e9d91ea6 \
    && cp ihx2sms/Linux/ihx2sms /tmp/sdcc/bin \
    && cp makesms/Linux/makesms /tmp/sdcc/bin \
    && cp folder2c/Linux/folder2c /tmp/sdcc/bin \
    && cp assets2banks/src/assets2banks.py /tmp/sdcc/bin/assets2banks \
    && chmod +x /tmp/sdcc/bin/assets2banks \
    && mkdir -p /tmp/sdcc/share/sdcc/lib/sms \
    && mkdir -p /tmp/sdcc/share/sdcc/include/sms \
    && cp crt0/crt0_sms.rel /tmp/sdcc/share/sdcc/lib/sms \
    && cp SMSlib/SMSlib.lib /tmp/sdcc/share/sdcc/lib/sms \
    && cp SMSlib/SMSlib_GG.lib /tmp/sdcc/share/sdcc/lib/sms \
    && cp SMSlib/src/SMSlib.h /tmp/sdcc/share/sdcc/include/sms \
    && cp SMSlib/src/peep-rules.txt /tmp/sdcc/share/sdcc/lib/sms \
    && cp PSGlib/PSGlib.rel /tmp/sdcc/share/sdcc/lib/sms \
    && cp PSGlib/src/PSGlib.h /tmp/sdcc/share/sdcc/include/sms

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

# retcon-util-audio
RUN curl -o retcon-audio-0.0.5-linux-amd64 -L "https://github.com/retcon85/retcon-util-audio/releases/download/0.0.5/retcon-audio-0.0.5-linux-amd64.bz2" \
    && tar -xvjf retcon-audio-0.0.5-linux-amd64 \
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

# copy devkitsms
COPY --from=devkitsms-builder /tmp/sdcc/ /usr/local/

# copy wla-dx
COPY --from=wla-dx-builder /tmp/wla-dx/bin/* /usr/local/bin/

# copy retcon-utils
COPY --from=utils-builder /tmp/local/bin/* /usr/local/bin/

# copy misc docker image utils
COPY ./export-h.sh /usr/local/bin/export-h
RUN chmod +x /usr/local/bin/export-h
COPY ./zsh-function /home/sms-tk/

RUN useradd -m sms-tk
USER sms-tk

WORKDIR /home/sms-tk
ENV HOME=/home/sms-tk

ENTRYPOINT [ "/bin/bash" ]
