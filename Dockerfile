FROM ubuntu:xenial

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		cron \
		duplicity \
		lftp \
		postgresql-client \
		python-paramiko \
		openssh-client \
	&& rm -rf /var/lib/apt/lists/*
	
COPY backup.sh /opt/
COPY start.sh /opt/

RUN chmod u+x /opt/*.sh

VOLUME /backup

CMD ["/opt/start.sh"]