FROM ubuntu:24.04

LABEL maintainer="doug.ashbaugh@outlook.com"
LABEL description="ComedyTrail Application - Ubuntu 24.04 LTS with Nginx, Laravel Jetstream, VNC, Gnome Desktop, Firefox"

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV DISPLAY=:1
ENV VNC_PORT=5901

# Set environment variables for language and encoding
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

EXPOSE 80 443 5901 22

WORKDIR /var/www/comedytrail

# Install system dependencies: Ubuntu base, Nginx, PHP 8.4, VNC, Xfce Desktop, Firefox, SSH
RUN apt update && \
    apt install -y --no-install-recommends software-properties-common && \
    add-apt-repository -y ppa:ondrej/php && \
    apt update && \
    apt install -y --no-install-recommends \
    systemd systemd-sysv \
    nginx \
    php8.4 php8.4-cli php8.4-fpm php8.4-mysql php8.4-pdo php8.4-xml php8.4-curl php8.4-mbstring php8.4-zip php8.4-bcmath \
    php8.4-dev \
    composer \
    git \
    curl wget \
    locales \
    openssh-server openssh-client \
    tightvncserver \
    xfonts-base xfonts-encodings xfonts-75dpi \
    xauth x11-xserver-utils \
    xfce4 xfce4-terminal \
    dbus dbus-user-session dbus-x11 \
    supervisor \
    mysql-client \
    nano vim \
    unzip

# Install Node.js using n
RUN apt update && \
    apt install -y --no-install-recommends \
    nodejs npm && \
    npm install -g n && \
    n lts && \
    npm install -g npm@latest
    
RUN locale-gen en_US.UTF-8;

# Mask services that don't work in containers
RUN systemctl mask systemd-logind.service getty.target php8.3-fpm.service php8.4-fpm.service

# Configure SSH
RUN mkdir -p /run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo 'root:comedytrail' | chpasswd && \
    systemctl enable ssh

# Configure Nginx for Laravel with PHP 8.4-FPM
RUN printf 'server {\n    listen 80 default_server;\n    listen [::]:80 default_server;\n    listen 443 ssl http2 default_server;\n    listen [::]:443 ssl http2 default_server;\n    \n    server_name _;\n    root /var/www/comedytrail/public;\n    index index.php index.html;\n    \n    ssl_certificate /etc/ssl/certs/comedytrail.crt;\n    ssl_certificate_key /etc/ssl/private/comedytrail.key;\n    \n    location ~ \\.php$ {\n        fastcgi_pass unix:/run/php/php8.4-fpm.sock;\n        fastcgi_index index.php;\n        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;\n        include fastcgi_params;\n    }\n    \n    location / {\n        try_files $uri $uri/ /index.php?$query_string;\n    }\n    \n    location ~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {\n        expires 1y;\n        add_header Cache-Control "public, immutable";\n    }\n}\n' > /etc/nginx/sites-available/comedytrail.conf && \
    rm -f /etc/nginx/sites-enabled/default && \
    rm -f /etc/nginx/sites-enabled/default.conf && \
    ln -sf /etc/nginx/sites-available/comedytrail.conf /etc/nginx/sites-enabled/default.conf

# Generate self-signed SSL certificate
RUN mkdir -p /etc/ssl/certs /etc/ssl/private && \
    openssl req -x509 -newkey rsa:2048 -keyout /etc/ssl/private/comedytrail.key -out /etc/ssl/certs/comedytrail.crt -days 365 -nodes -subj "/C=US/ST=State/L=City/O=Organization/CN=comedytrail"

# Create VNC startup service
RUN mkdir -p /etc/systemd/system && \
    printf '[Unit]\nDescription=TightVNC Server\nAfter=network.target\n\n[Service]\nType=simple\nUser=root\nExecStartPre=/bin/bash -c "rm -rf /tmp/.X*"\nExecStart=/usr/bin/Xvnc :1 -geometry 1920x1080 -depth 24 -rfbport 5901\nExecStop=/bin/true\nRestart=on-failure\nRestartSec=3\n\n[Install]\nWantedBy=multi-user.target\n' > /etc/systemd/system/tightvnc.service

# Create Xfce4 Session service
RUN printf '[Unit]\nDescription=Xfce4 Desktop Environment\nAfter=tightvnc.service\n\n[Service]\nType=simple\nUser=root\nEnvironment="DISPLAY=:1"\nExecStart=/usr/bin/startxfce4\nRestart=on-failure\nRestartSec=3\n\n[Install]\nWantedBy=multi-user.target\n' > /etc/systemd/system/xfce-session.service

# Create Nginx service
RUN printf '[Unit]\nDescription=Nginx Web Server\nAfter=network.target\n\n[Service]\nType=simple\nPIDFile=/var/run/nginx.pid\nExecStart=/usr/sbin/nginx -g "daemon off;"\nExecReload=/bin/kill -s HUP $MAINPID\nExecStop=/bin/kill -s QUIT $MAINPID\nKillMode=process\nRestart=on-failure\nRestartSec=3\n\n[Install]\nWantedBy=multi-user.target\n' > /etc/systemd/system/nginx.service

# Create PHP-FPM service
RUN printf '[Unit]\nDescription=PHP 8.4 FastCGI Process Manager\nAfter=network.target\n\n[Service]\nType=simple\nExecStart=/usr/sbin/php-fpm8.4 -F\nRestart=on-failure\nRestartSec=3\n\n[Install]\nWantedBy=multi-user.target\n' > /etc/systemd/system/php-fpm.service

# Enable services
RUN systemctl enable tightvnc.service xfce-session.service nginx.service php-fpm.service

# Create VNC config and xstartup
RUN mkdir -p /root/.vnc && \
    echo "comedytrail" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# Misc Permissions - Needed else nginx does not start
RUN chmod -f 777 /run

RUN cat > /root/.vnc/xstartup <<'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export DISPLAY=:1
eval $(dbus-launch --sh-syntax)
exec startxfce4
EOF

# Desktop Permissions
RUN chmod -f +x /root/.vnc/xstartup

# Xauth and X11 setup
RUN touch /root/.Xauthority && chmod -f 600 /root/.Xauthority

# Copy entrypoint script
COPY start-comedytrail.sh /usr/local/bin/start-comedytrail.sh
RUN chmod +x /usr/local/bin/start-comedytrail.sh

ENTRYPOINT ["/usr/local/bin/start-comedytrail.sh"]
