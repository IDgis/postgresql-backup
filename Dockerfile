FROM ubuntu:22.04

RUN \
	apt-get update \
	&& apt-get install -y curl gnupg \
	&& echo deb http://apt.postgresql.org/pub/repos/apt/ jammy-pgdg main > /etc/apt/sources.list.d/pgdg.list \
	&& curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | tee /etc/apt/trusted.gpg.d/postgresql.asc \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends \
		cron \
		duplicity \
		lftp \
		postgresql-client-9.5 \
		postgresql-client-9.6 \
		postgresql-client-10 \
		postgresql-client-11 \
		postgresql-client-12 \
		postgresql-client-13 \
		postgresql-client-14 \
		postgresql-client-15 \
		postgresql-client-16 \
		python3-paramiko \
		openssh-client \
	&& rm -rf /var/lib/apt/lists/*

COPY backup.sh /opt/
COPY start.sh /opt/
COPY restore.sh /opt/

RUN chmod u+x /opt/*.sh

VOLUME /backup

CMD ["/opt/start.sh"]
