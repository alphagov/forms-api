ARG ALPINE_VERSION=3.21
ARG RUBY_VERSION=3.4.1

ARG DOCKER_IMAGE_DIGEST=sha256:e5c30595c6a322bc3fbaacd5e35d698a6b9e6d1079ab0af09ffe52f5816aec3b

FROM ruby:${RUBY_VERSION}-alpine${ALPINE_VERSION}@${DOCKER_IMAGE_DIGEST} AS base

FROM base AS build

WORKDIR /app

RUN apk update
RUN apk upgrade --available
RUN apk add libc6-compat openssl-dev build-base libpq-dev
# Adding git so that we can bundle install gems from github
RUN apk add git
RUN adduser -D ruby

USER ruby

COPY --chown=ruby:ruby .ruby-version ./
COPY --chown=ruby:ruby Gemfile* ./

ARG BUNDLE_WITHOUT=development:test
RUN [ -z "$BUNDLE_WITHOUT" ] || bundle config set --local without "$BUNDLE_WITHOUT"
RUN bundle config set --local jobs "$(nproc)"

RUN bundle install

ARG RAILS_ENV
ENV RAILS_ENV="${RAILS_ENV:-production}" \
    PATH="${PATH}:/home/ruby/.local/bin" \
    USER="ruby" \
    REDIS_URL="${REDIS_URL:-redis://notset/}"

COPY --chown=ruby:ruby . .

FROM base AS app

ENV RAILS_ENV="${RAILS_ENV:-production}" \
    PATH="${PATH}:/home/ruby/.local/bin" \
    USER="ruby"

WORKDIR /app

RUN apk update
RUN apk upgrade --available
RUN apk add libc6-compat openssl-dev libpq

RUN adduser -D ruby
RUN chown ruby:ruby -R /app

USER ruby

COPY --chown=ruby:ruby bin/ ./bin
RUN chmod 0755 bin/*

COPY --chown=ruby:ruby --from=build /usr/local/bundle /usr/local/bundle
COPY --chown=ruby:ruby --from=build /app /app

RUN mkdir -p "/app/tmp/" && chown ruby:ruby "/app/tmp/" && chown ruby:ruby "/app/db/"
VOLUME "/tmp/"
VOLUME "/app/tmp/"
VOLUME "/app/db/"

EXPOSE 9292

CMD ["/bin/sh", "-o", "xtrace", "-c", "rails s -b 0.0.0.0 -p 9292"]
