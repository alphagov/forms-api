FROM ruby:3.1.1-alpine

RUN apk --no-cache add postgresql-dev postgresql-libs postgresql-client less

WORKDIR /app
COPY .ruby-version Gemfile Gemfile.lock ./
RUN apk --no-cache add alpine-sdk && bundle install && apk del alpine-sdk

ADD . /app

EXPOSE 9292
CMD bundle exec rackup
