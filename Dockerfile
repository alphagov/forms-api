FROM ruby:3.1.2-alpine3.16@sha256:05b990dbaa3a118f96e9ddbf046f388b3c4953d5ef3d18908af96f42c0e138d9

RUN apk update
RUN apk upgrade --available
RUN apk --no-cache add libpq-dev

WORKDIR /app
COPY .ruby-version Gemfile Gemfile.lock ./
RUN apk --no-cache add alpine-sdk && bundle install && apk del alpine-sdk

RUN adduser -D ruby
USER ruby

# Consider whittling this down to just what we need to run the app
COPY --chown=ruby:ruby . .

EXPOSE 9292
CMD ["rackup", "--host", "0.0.0.0", "--port", "9292"]
