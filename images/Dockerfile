FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies and runtime tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libjack-jackd2-dev \
    libsndfile1-dev \
    libfftw3-dev \
    libxt-dev \
    libavahi-client-dev \
    libudev-dev \
    libasound2-dev \
    libicu-dev \
    libreadline-dev \
    pkg-config \
    libncurses5-dev \
    pipewire \
    pipewire-audio-client-libraries \
    pipewire-pulse \
    rtkit \
    darkice \
    icecast2 \
    alsa-utils \
    lame \
    nano \
    dbus \
    dbus-user-session \
    ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Build SuperCollider 3.14.1 from source (headless)
RUN cd /tmp && \
    git clone --branch Version-3.14.1 --recurse-submodules https://github.com/SuperCollider/SuperCollider.git && \
    cd SuperCollider && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DSC_QT=OFF \
          -DSC_IDE=OFF \
          -DSC_ED=OFF \
          -DSC_EL=OFF \
          -DSC_VIM=OFF \
          -DNATIVE=ON \
          -DCMAKE_INSTALL_PREFIX=/usr/local \
          .. && \
    make -j$(nproc) && \
    make install && \
    cd /tmp && rm -rf SuperCollider

RUN adduser --disabled-password --gecos "" scuser && \
    usermod -a -G audio,video scuser && \
    mkdir -p /var/log/icecast && \
    chown scuser:scuser /var/log/icecast && \
    mkdir -p /run/user/1000 && \
    chown scuser:scuser /run/user/1000

RUN echo "@audio   -  rtprio     95" >> /etc/security/limits.conf && \
    echo "@audio   -  memlock    unlimited" >> /etc/security/limits.conf && \
    echo "@audio   -  nice      -10" >> /etc/security/limits.conf

COPY icecast.xml /etc/icecast2/icecast.xml
COPY darkice.cfg /etc/darkice.cfg
COPY autostart.scd /home/scuser/autostart.scd

# ENTRY SCRIPT FOR CLOUD
RUN echo '#!/bin/bash\n\
export XDG_RUNTIME_DIR=/run/user/1000\n\
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus\n\
ulimit -r 95 2>/dev/null || true\n\
ulimit -l unlimited 2>/dev/null || true\n\
\n\
# Start dbus\n\
dbus-daemon --session --address=$DBUS_SESSION_BUS_ADDRESS --nofork --nopidfile &\n\
sleep 1\n\
\n\
# Start pipewire audio system\n\
pipewire &\n\
sleep 1\n\
pipewire-pulse &\n\
sleep 2\n\
pw-loopback --capture-props="media.class=Audio/Source" \
            --playback-props="node.description=SuperColliderOutput" &\n\
sleep 2\n\
\n\
# Start icecast streaming server\n\
icecast2 -c /etc/icecast2/icecast.xml &\n\
echo "Waiting for icecast to start..."\n\
sleep 5\n\
\n\
# Start SuperCollider with ALSA backend\n\
SC_JACK_DEFAULT_OUTPUTS="system" SC_AUDIODRIVER="ALSA" sclang /home/scuser/autostart.scd &\n\
sleep 10\n\
\n\
# Start darkice encoder (connects to icecast)\n\
echo "Starting darkice..."\n\
darkice -c /etc/darkice.cfg\n' > /entrypoint.sh && chmod +x /entrypoint.sh

USER scuser

EXPOSE 8000 8001
ENTRYPOINT ["/entrypoint.sh"]

