FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies, Xvfb, X11VNC, noVNC, fluxbox, and Firefox
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    fluxbox \
    net-tools \
    curl \
    git \
    novnc \
    websockify \
    firefox \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Setup a working directory for noVNC
WORKDIR /root/noVNC

# Configure Supervisor to manage Xvfb, Fluxbox, x11vnc, Firefox, and noVNC
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Render assigns a dynamic port via $PORT environment variable
EXPOSE 8080

# Entrypoint script to substitute PORT and run supervisor
CMD ["/bin/bash", "-c", "sed -i 's/PORT/\\'$PORT'/' /etc/supervisor/conf.d/supervisord.conf && /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf"]
