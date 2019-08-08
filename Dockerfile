ARG api_key
ARG domain
ARG subdomains
ARG ttl=300
ARG checker=http://ifconfig.me/ip

FROM jfloff/alpine-python:2.7

RUN apk add --no-cache  unzip  git && pip install requests args simplejson

RUN git clone https://github.com/cavebeat/gandi-live-dns.git app
WORKDIR /app
RUN echo "#!/usr/bin/env python\n# encoding: utf-8\napi_secret = '${api_key}'\napi_endpoint = 'https://dns.api.gandi.net/api/v5'\ndomain = '#{domain}'\nsubdomains = [${subdomains}]\nttl = '${ttl}\nifconfig = '${checker}'" > config.py
RUN echo "/5 * * * * cd app && gandi-live-dns.py >/dev/null 2>&1" > /app/crontab.txt
RUN echo "#!/bin/sh\n\n/usr/sbin/crond -f -l 8" > /app/entry.sh
RUN chmod 755 /app/entry.sh

CMD ["cd app && ./entry.sh"]
