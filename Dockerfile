FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies including Node.js
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    fluxbox \
    net-tools \
    curl \
    git \
    novnc \
    supervisor \
    software-properties-common \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install the proxy library needed for our bridge script
RUN npm install -g http-proxy

# Add non-snap Firefox
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: firefox*\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001' > /etc/apt/preferences.d/mozilla-firefox && \
    apt-get update && apt-get install -y firefox && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root/noVNC

# Copy all configuration files
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY bridge.js /root/noVNC/bridge.js

# Link global modules so our script can find http-proxy
ENV NODE_PATH=/usr/local/lib/node_modules

# Ensure Back4app detects the main port
EXPOSE 8080

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
