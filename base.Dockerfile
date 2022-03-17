FROM ruby:2.5.5-alpine3.8

RUN mkdir -p /srv/code

WORKDIR /srv/code

RUN apk add --update \
  curl curl-dev \
  libxml2-dev \
  build-base \
  libxml2-dev \
  libxslt-dev \
  mysql-client \
  mysql-dev \
  tzdata \
  nodejs \
  linux-headers \
  pcre pcre-dev
