FROM php:8.2-fpm

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 DEBIAN_FRONTEND=noninteractive
ENV ACCEPT_EULA=Y

RUN apt-get update && \
    apt-get -y --no-install-recommends install \
    libssl-dev zlib1g-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev \
    libonig-dev openssh-server vim iproute2 tcpdump libzip-dev zip libicu-dev bash-completion grc gnupg2 libpq-dev
#RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
#RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
#RUN apt-get update
#RUN ACCEPT_EULA=Y apt-get -y --no-install-recommends install msodbcsql17 unixodbc-dev
#RUN pecl install sqlsrv
#RUN pecl install pdo_sqlsrv
#RUN docker-php-ext-enable sqlsrv pdo_sqlsrv
RUN pecl install -o -f redis
RUN docker-php-source extract
RUN docker-php-ext-install -j$(nproc) mysqli pdo_mysql ftp fileinfo gd gettext mbstring zip intl pdo_pgsql
RUN docker-php-ext-enable redis
RUN docker-php-source delete
RUN pecl install xdebug
COPY config/xdebug.ini /usr/local/etc/php/conf.d/

RUN mkdir -p /var/log/php
RUN chown www-data:www-data /var/log/php
RUN sed -i "s/;php_admin_flag\[log_errors\]/php_admin_flag[log_errors]/" /usr/local/etc/php-fpm.d/www.conf
RUN apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* && \
	rm -rf /tmp/pear

ENV TZ=Europe/Budapest
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
COPY config/tzone.ini /usr/local/etc/php/conf.d/

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); exit(1); } echo PHP_EOL;"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/bin/composer
RUN chmod a+x /usr/bin/composer

RUN curl -sS https://get.symfony.com/cli/installer | bash
ENV PATH="$PATH:/root/.composer/vendor/bin:/root/.symfony5/bin"

#ADD config/symfony_completion.sh /etc/bash_completion.d/symfony_completion.sh
RUN echo ". /etc/bash_completion" >> /root/.bashrc
#ADD config/conf.log /usr/share/grc/conf.log
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
RUN sed -i 's/^memory_limit = .*$/memory_limit = 4G/' /usr/local/etc/php/php.ini

WORKDIR /app
