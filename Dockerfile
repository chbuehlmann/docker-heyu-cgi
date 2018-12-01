FROM ubuntu:18.04 as builder

RUN apt-get update -y &&\
	apt-get install -y build-essential

RUN apt-get install -y wget

RUN wget https://github.com/HeyuX10Automation/heyu/archive/v2.10.1.tar.gz -O heyu-2.10.tar.gz &&\
	tar xf heyu-2.10.tar.gz&&\
	cd heyu-2.10.1 &&\
	sh ./Configure &&\
	make
	
FROM ubuntu:18.04

ENV APACHE_RUN_USER=www-data \
	 APACHE_RUN_GROUP=www-data \
	 APACHE_PID_FILE=/var/run/apache2/apache2.pid \
	 APACHE_RUN_DIR=/var/run/apache2 \
	 APACHE_LOCK_DIR=/var/lock/apache2 \
	 APACHE_LOG_DIR=/var/log/apache2 \
	 LANG=C

WORKDIR /root/heyu/
COPY --from=builder /heyu-2.10.1 .
ADD x10.conf /etc/heyu/

RUN apt-get update -y &&\
	apt-get install -y make apache2 &&\
	apt-get clean
RUN mkdir /var/tmp/heyu &&\
	chown www-data:www-data /var/tmp/heyu &&\
	make install &&\
	a2enmod cgi
	
ADD --chown=www-data:www-data cgi-bin/* /usr/lib/cgi-bin/

WORKDIR /
RUN rm -rf /root/heyu/ &&\
	sed -i '/Listen/{s/\([0-9]\+\)/8080/; :a;n; ba}' /etc/apache2/ports.conf
	
EXPOSE 80

CMD ["apache2ctl", "-DFOREGROUND"]