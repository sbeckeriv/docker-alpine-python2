ARG api_key
ARG domain
ARG subdomains
ARG ttl=300
ARG checker=http://ifconfig.me/ip

FROM alpine:3.10

RUN apk add --no-cache python unzip python-requests python-args python-simplejson git && \
    python -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip install --upgrade pip setuptools && \
    rm -r /root/.cache
RUN git clone https://github.com/cavebeat/gandi-live-dns.git app
WORKDIR /app
RUN echo "#!/usr/bin/env python\n# encoding: utf-8\napi_secret = '${api_key}'\napi_endpoint = 'https://dns.api.gandi.net/api/v5'\ndomain = '#{domain}'\nsubdomains = [${subdomains}]\nttl = '${ttl}\nifconfig = '${checker}'" > config.py
RUN echo "/5 * * * * /root/gandi-live-dns-master/src/gandi-live-dns.py >/dev/null 2>&1" |crontab - && crond -f -L /dev/stdout
