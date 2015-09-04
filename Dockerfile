FROM ubuntu:trusty
MAINTAINER Kohei MATSUSHITA <ma2shita+git@ma2shita.jp>

ENV APP_ROOT /opt/moodle
ENV DEBIAN_FRONTEND noninteractive

RUN adduser --disabled-password --gecos moodle moodleuser

RUN cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    echo 'Asia/Tokyo' > /etc/timezone && \
    echo 'LC_ALL=ja_JP.UTF-8' > /etc/default/locale && \
    echo 'LANG=ja_JP.UTF-8' >> /etc/default/locale && \
    locale-gen ja_JP.UTF-8
RUN sed -e 's;http://archive;http://jp.archive;' -e  's;http://us\.archive;http://jp.archive;' -i /etc/apt/sources.list

RUN apt-get update && \
apt-get -y install apache2 libapache2-mod-php5 php5-cli php5-gd php5-mysqlnd php5-curl php5-xmlrpc php5-intl php5-apcu php5-mcrypt postfix wget curl supervisor mysql-server mysql-client pwgen git unzip vim
RUN apt-get clean && rm -rf /var/cache/apt/archives/*
RUN rm -rf /var/lib/mysql/*

RUN mkdir $APP_ROOT && \
    git clone -b MOODLE_29_STABLE --depth 1 git://git.moodle.org/moodle.git $APP_ROOT/app
RUN chown -R root:root $APP_ROOT/app && \
    chmod 0755 $APP_ROOT/app

COPY *.sh /
RUN chmod 755 /*.sh
COPY my.cnf /etc/mysql/conf.d/
COPY supervisord-*.conf /etc/supervisor/conf.d/

ADD ports_default /etc/apache2/ports.conf
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN rm -f /var/log/apache2/*log && \
    ln -s /dev/stdout /var/log/apache2/access.log && \
    ln -s /dev/stderr /var/log/apache2/error.log
RUN a2enmod rewrite

ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M
EXPOSE 80
VOLUME ["/var/lib/mysql", "$APP_ROOT/moodledata"]
CMD ["/run.sh"]
