ARG api_key
ARG domain
ARG subdomains
ARG ttl=300
ARG checker=http://ifconfig.me/ip

FROM jfloff/alpine-python:2.7

RUN apk add --no-cache  unzip  git && pip install requests args simplejson

RUN git clone https://github.com/cavebeat/gandi-live-dns.git app
WORKDIR /app
RUN echo "#!/usr/bin/env python" > config.py
RUN echo "# encoding: utf-8" >> config.py
RUN echo "api_secret = '${api_key}'" >> config.py
RUN echo "api_endpoint = 'https://dns.api.gandi.net/api/v5'" >> config.py
RUN echo "domain = '#{$domain}'" >> config.py
RUN echo "subdomains = [${subdomains}]" >> config.py
RUN echo "ttl = '300'" >> config.py
RUN echo "ifconfig = 'http://ifconfig.me/ip'" >> config.py




RUN echo "/5 * * * * cd app && gandi-live-dns.py >/dev/null 2>&1" > /app/crontab.txt
RUN echo "#!/bin/sh" > /app/entry.sh
RUN echo "/usr/sbin/crond -f -l 8" >> /app/entry.sh

RUN chmod 755 /app/entry.sh
RUN echo 'ping localhost &' > /bootstrap.sh
RUN echo 'sleep 100000' >> /bootstrap.sh
RUN chmod +x /bootstrap.sh

CMD ./entry.sh

