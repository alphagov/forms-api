FROM ruby:3.2.2-alpine3.18@sha256:198e97ccb12cd0297c274d10e504138f412f90bed50c36ebde0a466ab89cf526 AS build

WORKDIR /app

RUN apk update
RUN apk upgrade --available
RUN apk add libc6-compat openssl-dev build-base libpq-dev
# Adding git so that we can bundle install gems from github
RUN apk add git
RUN adduser -D ruby

USER ruby

COPY --chown=ruby:ruby Gemfile* ./
RUN gem install bundler -v 2.4.10

RUN bundle config set --local without development:test \
  && bundle config set --local jobs "$(nproc)"

RUN bundle install

ENV RAILS_ENV="${RAILS_ENV:-production}" \
    PATH="${PATH}:/home/ruby/.local/bin" \
    USER="ruby" \
    REDIS_URL="${REDIS_URL:-redis://notset/}"

COPY --chown=ruby:ruby . .

FROM ruby:3.2.2-alpine3.18@sha256:198e97ccb12cd0297c274d10e504138f412f90bed50c36ebde0a466ab89cf526 AS app

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

EXPOSE 9292

CMD ["/bin/sh", "-o", "xtrace", "-c", "rake db:migrate && rails s -b 0.0.0.0 -p 9292"]
