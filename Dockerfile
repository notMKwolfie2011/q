FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies, Xvfb, X11VNC, noVNC, fluxbox, and supervisor
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    fluxbox \
    net-tools \
    curl \
    git \
    novnc \
    websockify \
    supervisor \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Add official Mozilla PPA to get the non-snap version of Firefox
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: firefox*\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001' > /etc/apt/preferences.d/mozilla-firefox && \
    apt-get update && apt-get install -y firefox && \
    rm -rf /var/lib/apt/lists/*

# Setup a working directory for noVNC
WORKDIR /root/noVNC

# Configure Supervisor to manage Xvfb, Fluxbox, x11vnc, Firefox, and noVNC
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Force Firefox to use software rendering to save memory
ENV MOZ_ENABLE_WAYLAND=0
ENV MOZ_WEBRENDER=0

# Render assigns a dynamic port via $PORT environment variable
EXPOSE 8080

# Entrypoint script to substitute PORT and run supervisor safely
CMD ["/bin/bash", "-c", "sed -i \"s/PORT/$PORT/g\" /etc/supervisor/conf.d/supervisord.conf && /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf"]
