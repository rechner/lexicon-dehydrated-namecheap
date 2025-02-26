FROM python:3.9-alpine

# Setup dependencies
# Install dehydrated (letsencrypt client) & dns-lexicon
RUN apk add --no-cache bash bind-tools curl git openssl \
      gcc musl-dev python3-dev libffi-dev openssl-dev cargo \
 && git clone --depth 1 https://github.com/lukas2511/dehydrated.git /srv/dehydrated \
 && pip install --no-cache-dir dns-lexicon dns-lexicon[namecheap] dns-lexicon[cloudflare]\
 && apk del git gcc musl-dev python3-dev libffi-dev openssl-dev cargo

VOLUME /data

ENV PROVIDER=namecheap

ENV PROVIDER_UPDATE_DELAY=300

# Thanks to Rycieos for the dockerfile
COPY --chmod=755 ./dehydrated.default.sh /srv/dehydrated/

COPY config /srv/dehydrated/

RUN apt update \
    && apt install -y bsdmainutils \
    && apt-get clean \
    && pip install dns-lexicon

ENTRYPOINT ["srv/dehydrated/dehydrated"]
CMD ["--cron", "--accept-terms", "--hook", "/srv/dehydrated/dehydrated.default.sh", "--challenge", "dns-01"]
