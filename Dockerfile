ARG BASE_VERSION="3.0"
ARG BASE_VARIANT="bookworm"
ARG DEVKIT_SMS_SHA="8b99400a9b046f33fc6b03708cab880af8e334cd"

FROM ghcr.io/retcon85/toolchain-base:${BASE_VERSION}-${BASE_VARIANT} AS base

FROM base AS builder-base

RUN apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get -y install --no-install-recommends \
    build-essential \
    tcl-dev \
    && apt-get autoclean && apt-get clean && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists

# ----------------------------- #
# utils                         #
# ----------------------------- #
FROM builder-base AS utils-builder

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
# devkitSMS                     #
# ----------------------------- #
FROM builder-base AS devkitsms-builder

WORKDIR /tmp

RUN git clone --branch master --single-branch https://github.com/sverx/devkitSMS.git \
    && cd devkitSMS \
    && git checkout ${DEVKIT_SMS_SHA}

COPY ./build_devkitsms.sh ./devkitSMS/
COPY ./Makefile_SGlib ./devkitSMS/SGlib/src/Makefile

RUN cd devkitSMS \
    && chmod +x ./build_devkitsms.sh \
    && use-sdcc 4.3 \
    && ./build_devkitsms.sh 4.3\
    && use-sdcc 4.4 \
    && ./build_devkitsms.sh 4.4 \
    && use-sdcc 4.5 \
    && ./build_devkitsms.sh 4.5

# ----------------------------- #
# zasm assmebler                #
# ----------------------------- #

FROM builder-base AS zasm-builder

WORKDIR /tmp

RUN git clone --recurse-submodules --single-branch --branch 4.5.0 https://github.com/Megatokio/zasm.git \
    && cd zasm \
    && make \
    && mkdir -p /tmp/local/bin \
    && mv ./zasm /tmp/local/bin

# ----------------------------- #
# FINAL IMAGE COMPILATION       #
# ----------------------------- #

FROM base

# copy devkitsms from builder images
COPY --from=devkitsms-builder /tmp/devkitsms-4.3/ /opt/devkitsms-4.3/
COPY --from=devkitsms-builder /tmp/devkitsms-4.4/ /opt/devkitsms-4.4/
COPY --from=devkitsms-builder /tmp/devkitsms-4.5/ /opt/devkitsms-4.5/

# copy retcon-utils
COPY --from=utils-builder /tmp/local/bin/* /usr/local/bin/

# copy zasm
COPY --from=zasm-builder /tmp/local/bin/* /usr/local/bin/

# copy misc docker image utils
COPY ./export-h.sh /usr/local/bin/export-h
COPY ./zsh-function /home/retcon/

# override use-sdcc script from base
RUN cp /usr/local/bin/use-sdcc /usr/local/bin/use-sdcc-base
COPY ./use-sdcc.sh /usr/local/bin/use-sdcc

# symlink default devkitsms for SDCC version (4.3)
# chmod scripts
RUN ln -s /opt/sdcc-4.3 /opt/sdcc \
    && ln -s /opt/devkitsms-4.3 /opt/devkitsms \
    && chmod +x /usr/local/bin/use-sdcc

# add devkitsms to path
ENV PATH=/opt/devkitsms/bin:$PATH

# chmod scripts
RUN chmod +x /usr/local/bin/export-h

WORKDIR /home/retcon
ENV HOME=/home/retcon
USER root
ENTRYPOINT ["/bin/sh", "-c"]
