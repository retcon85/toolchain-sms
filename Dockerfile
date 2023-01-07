# ------------------------------------------------- #
# base installs python3 for general purpose tooling #
# ------------------------------------------------- #

FROM python:3.11.0 AS smstk-base

# ----------------------------- #
# common tools                  #
# ----------------------------- #

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
RUN curl -o sdcc-src-4.2.0.tar.bz2 -L "https://downloads.sourceforge.net/project/sdcc/sdcc/4.2.0/sdcc-src-4.2.0.tar.bz2" \
    && tar -xvjf sdcc-src-4.2.0.tar.bz2 \
    && cd sdcc-4.2.0 \
    && ./configure --disable-pic14-port --disable-pic16-port \
    && make \
    && make install prefix=/tmp/sdcc
RUN git clone --branch master --single-branch https://github.com/sverx/devkitSMS.git \
    && cd devkitSMS \
    && git checkout 1688872ca0576ab765a0f7904a93ba0fd391f66a \
    && cp ihx2sms/Linux/ihx2sms /tmp/sdcc/bin \
    && cp makesms/Linux/makesms /tmp/sdcc/bin \
    && cp folder2c/Linux/folder2c /tmp/sdcc/bin \
    && mkdir -p /tmp/sdcc/util \
    && cp assets2banks/src/assets2banks.py /tmp/sdcc/util/assets2banks \
    && chmod +x /tmp/sdcc/util/assets2banks \
    && mkdir -p /tmp/sdcc/share/sdcc/lib/sms \
    && mkdir -p /tmp/sdcc/share/sdcc/include/sms \
    && cp crt0/crt0_sms.rel /tmp/sdcc/share/sdcc/lib/sms \
    && cp SMSlib/SMSlib.lib /tmp/sdcc/share/sdcc/lib/sms \
    && cp SMSlib/src/SMSlib.h /tmp/sdcc/share/sdcc/include/sms \
    && cp SMSlib/src/peep-rules.txt /tmp/sdcc/share/sdcc/lib/sms \
    && cp PSGlib/PSGlib.rel /tmp/sdcc/share/sdcc/lib/sms \
    && cp PSGlib/src/PSGlib.h /tmp/sdcc/share/sdcc/include/sms

# ----------------------------- #
# retcon utils                  #
# ----------------------------- #
FROM smstk-builder-base AS retcon-utils-builder
WORKDIR /tmp
RUN mkdir -p local/bin
RUN git clone --branch v0.2 --single-branch https://github.com/retcon85/retcon-util-sms.git
RUN cp retcon-util-sms/img2tiles.py local/bin/img2tiles \
    && chmod +x local/bin/img2tiles

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
COPY --from=devkitsms-builder /tmp/sdcc/bin/ /usr/local/bin/
COPY --from=devkitsms-builder /tmp/sdcc/share/ /usr/local/share/
COPY --from=devkitsms-builder /tmp/sdcc/util/ /usr/local/bin/

# copy wla-dx
COPY --from=wla-dx-builder /tmp/wla-dx/bin/* /usr/local/bin/

# copy retcon-utils
COPY --from=retcon-utils-builder /tmp/local/bin/* /usr/local/bin/

RUN useradd -m sms-tk
USER sms-tk

WORKDIR /home/sms-tk
ENV HOME=/home/sms-tk

ENTRYPOINT [ "/bin/bash" ]
