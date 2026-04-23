FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    apache2 \
    php \
    php-pgsql \
    libapache2-mod-php \
    zip \
    sudo \
    postgresql \
    && rm -rf /var/lib/apt/lists/*

COPY setup/ /setup/
COPY web/ /var/www/html/

RUN chmod +x /setup/setup.sh /setup/start.sh && /setup/setup.sh

EXPOSE 22 80

CMD ["/setup/start.sh"]
