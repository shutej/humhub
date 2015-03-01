# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
FROM phusion/baseimage:0.9.16

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
    curl \
    git \
    imagemagick \
    nginx \
    php5-cli \
    php5-curl \
    php5-fpm \
    php5-gd \
    php5-ldap \
    php5-memcached \
    php5-mysql

# Override this from the command-line.
ENV HUMHUB_URL 127.0.0.1.xip.io

RUN mkdir -p /var/www/${HUMHUB_URL}/public_html && \
    mkdir -p /var/www/${HUMHUB_URL}/logs && \
    git clone https://github.com/humhub/humhub.git /var/www/${HUMHUB_URL}/public_html && \
    chown -R www-data: /var/www/${HUMHUB_URL}/public_html/ && \
    ln -s /var/www/${HUMHUB_URL}/public_html/protected/yiic /etc/cron.hourly/yiic && \
    ln -s /var/www/${HUMHUB_URL}/public_html/protected/yiic /etc/cron.daily/yiic

# Add the nginx.conf file to the right place and run it (with runit).
RUN mkdir -p /etc/service/nginx /etc/service/php5-fpm
ADD nginx.sh /etc/service/nginx/run
ADD php5-fpm.sh /etc/service/php5-fpm/run
ADD nginx.conf /etc/nginx/sites-available/${HUMHUB_URL}
RUN sed -i \
    "s/\${HUMHUB_URL}/${HUMHUB_URL}/" /etc/nginx/sites-available/${HUMHUB_URL} && \
    ln -s /etc/nginx/sites-available/${HUMHUB_URL} /etc/nginx/sites-enabled/${HUMHUB_URL}

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose ports
EXPOSE 80