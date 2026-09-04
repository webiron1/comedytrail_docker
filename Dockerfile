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

EXPOSE 80 443 5901

WORKDIR /var/www/comedytrail

# Install system dependencies: Ubuntu base, Nginx, PHP, VNC, Xfce Desktop, Firefox
RUN apt update && \
    apt install -y --no-install-recommends \
    systemd systemd-sysv \
    nginx \
    php php-cli php-fpm php-mysql php-pdo php-xml php-curl php-mbstring php-zip php-bcmath \
    php-dev \
    composer \
    git \
    curl wget \
    locales \
    tightvncserver \
    xfonts-base xfonts-encodings xfonts-75dpi \
    xauth x11-xserver-utils \
    xfce4 xfce4-terminal \
    dbus dbus-user-session dbus-x11 \
    supervisor \
    mysql-client \
    nano vim \
    unzip

# Install node
RUN apt update && \
    apt install -y --no-install-recommends \
    nodejs npm && \
    npm install -g n && \
    n stable && \
    apt purge -y nodejs npm
    
RUN locale-gen en_US.UTF-8;

# Mask services that don't work in containers
RUN systemctl mask systemd-logind.service getty.target

# Configure Nginx for Laravel
RUN printf 'server {\n    listen 80 default_server;\n    listen [::]:80 default_server;\n    listen 443 ssl http2 default_server;\n    listen [::]:443 ssl http2 default_server;\n    \n    server_name _;\n    root /var/www/comedytrail/comedytrail-app/public;\n    index index.php index.html;\n    \n    ssl_certificate /etc/ssl/certs/comedytrail.crt;\n    ssl_certificate_key /etc/ssl/private/comedytrail.key;\n    \n    location ~ \\.php$ {\n        fastcgi_pass unix:/run/php/php-fpm.sock;\n        fastcgi_index index.php;\n        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;\n        include fastcgi_params;\n    }\n    \n    location / {\n        try_files $uri $uri/ /index.php?$query_string;\n    }\n    \n    location ~* \\.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {\n        expires 1y;\n        add_header Cache-Control "public, immutable";\n    }\n}\n' > /etc/nginx/sites-available/comedytrail.conf && \
    ln -sf /etc/nginx/sites-available/comedytrail.conf /etc/nginx/sites-enabled/ && \
    rm -f /etc/nginx/sites-enabled/default

# Generate self-signed SSL certificate
RUN mkdir -p /etc/ssl/certs /etc/ssl/private && \
    openssl req -x509 -newkey rsa:2048 -keyout /etc/ssl/private/comedytrail.key -out /etc/ssl/certs/comedytrail.crt -days 365 -nodes -subj "/C=US/ST=State/L=City/O=Organization/CN=comedytrail"

# Create VNC startup service
RUN mkdir -p /etc/systemd/system && \
    printf '[Unit]\nDescription=TightVNC Server\nAfter=network.target\n\n[Service]\nType=simple\nUser=root\nExecStartPre=/bin/bash -c "rm -rf /tmp/.X*"\nExecStart=/usr/bin/Xvnc :1 -geometry 1920x1080 -depth 24 -rfbport 5901\nExecStop=/bin/true\nRestart=on-failure\nRestartSec=3\n\n[Install]\nWantedBy=multi-user.target\n' > /etc/systemd/system/tightvnc.service

# Create Xfce4 Session service
RUN printf '[Unit]\nDescription=Xfce4 Desktop Environment\nAfter=tightvnc.service\n\n[Service]\nType=simple\nUser=root\nEnvironment="DISPLAY=:1"\nExecStart=/usr/bin/startxfce4\nRestart=on-failure\nRestartSec=3\n\n[Install]\nWantedBy=multi-user.target\n' > /etc/systemd/system/xfce-session.service

# Create Nginx service
RUN printf '[Unit]\nDescription=Nginx Web Server\nAfter=network.target\n\n[Service]\nType=simple\nUser=www-data\nExecStart=/usr/sbin/nginx -g "daemon off;"\nExecReload=/bin/kill -s HUP $MAINPID\nExecStop=/bin/kill -s QUIT $MAINPID\nRestart=on-failure\nRestartSec=3\n\n[Install]\nWantedBy=multi-user.target\n' > /etc/systemd/system/nginx.service

# Create PHP-FPM service
RUN printf '[Unit]\nDescription=PHP FastCGI Process Manager\nAfter=network.target\n\n[Service]\nType=simple\nExecStart=/usr/sbin/php-fpm8.3 -F -O\nRestart=on-failure\nRestartSec=3\n\n[Install]\nWantedBy=multi-user.target\n' > /etc/systemd/system/php-fpm.service

# Enable services
RUN systemctl enable tightvnc.service xfce-session.service nginx.service php-fpm.service

# Create VNC config and xstartup
RUN mkdir -p /root/.vnc && \
    echo "comedytrail" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

RUN cat > /root/.vnc/xstartup <<'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export DISPLAY=:1
eval $(dbus-launch --sh-syntax)
exec startxfce4
EOF

RUN chmod +x /root/.vnc/xstartup

# Xauth and X11 setup
RUN touch /root/.Xauthority && chmod 600 /root/.Xauthority

# Create Laravel Jetstream project structure
RUN mkdir -p /var/www/comedytrail/comedytrail-app && \
    cd /var/www/comedytrail && \
    composer create-project laravel/laravel comedytrail-app

RUN cat > /var/www/comedytrail/comedytrail-app/.env <<'EOF'
APP_NAME=ComedyTrail
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://localhost

DB_CONNECTION=mysql
#DB_HOST=ComedyTrail_Database
DB_HOST=172.18.0.2
DB_PORT=3306
DB_DATABASE=comedytrail
DB_USERNAME=comedytrail_user
DB_PASSWORD=comedytrail_secret

CACHE_DRIVER=file
SESSION_DRIVER=file
EOF

RUN cd /var/www/comedytrail/comedytrail-app && \
    composer require laravel/jetstream && \
    php artisan jetstream:install livewire

RUN cd /var/www/comedytrail/comedytrail-app && \
    chown -R www-data:www-data /var/www/comedytrail && \
    chmod -R 755 /var/www/comedytrail/comedytrail-app/storage && \
    chmod -R 755 /var/www/comedytrail/comedytrail-app/bootstrap/cache

# Setup Laravel application: generate key, run migrations, set permissions
RUN cd /var/www/comedytrail/comedytrail-app && \
    php artisan key:generate && \
    php artisan migrate --force || true && \
    chown -Rf www-data:www-data /var/www/comedytrail

# Create .env file for Laravel
RUN mkdir -p /var/www/comedytrail/comedytrail-app && \
    touch /var/www/comedytrail/comedytrail-app/.env && \
    chown -R www-data:www-data /var/www/comedytrail/comedytrail-app && \
    chmod 644 /var/www/comedytrail/comedytrail-app/.env

# Install Firefox

# Download the latest Firefox Linux 64-bit binary
#RUN curl -L "https://mozilla.org" -o firefox-latest.tar.bz2

# Extract the archive directly to the /opt directory
#RUN tar -jxvf firefox-latest.tar.bz2 -C /opt/

# Remove the downloaded archive file
#RUN rm cd /tmp && firefox-latest.tar.bz2

# Create a symbolic link to the Firefox binary in /usr/local/bin for easy access
#RUN ln -s /opt/firefox/firefox /usr/local/bin/firefox

# Entrypoint script
RUN cat > /usr/local/bin/start-comedytrail.sh <<'EOF'
#!/bin/bash
echo "ComedyTrail Startup..."

# Wait for database
echo "Waiting for MySQL database..."
for i in {1..30}; do
    if mysql -h comedytrail_db -u comedytrail_user -pcomedytrail_secret -e "SELECT 1" &>/dev/null; then
        echo "Database is ready!"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 1
done

# Run migrations
cd /var/www/comedytrail/comedytrail-app && \
    php artisan migrate --force

# Start systemd
exec /lib/systemd/systemd
EOF

RUN chmod +x /usr/local/bin/start-comedytrail.sh

ENTRYPOINT ["/usr/local/bin/start-comedytrail.sh"]
