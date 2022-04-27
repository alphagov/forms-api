# GOV.UK Forms - API

`forms-api` is the API for the GOV.UK Forms platform. It is a Ruby application that is built using Sinatra, currently using a Postgresql database for data storage and is used for storing/serving the form configurations that are created by form creators.

## Before you start

To run the project you will need to install:

- [Ruby](https://www.ruby-lang.org/en/) - we use version 3 of Ruby. Before running the project, double check the [.ruby-version] file to see the exact version.
- a running [PostgreSQL](https://www.postgresql.org/) database

We recommend using a version manager to install and manage these, such as:

- [RVM](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv) for Ruby
- [asdf](https://github.com/asdf-vm/asdf) for Ruby (and many other languages)

## Getting started

### Installing for the first time

```bash
# 1. Clone the git repository and change directory to the new folder
git clone git@github.com:alphagov/forms-api.git
cd forms-api

# 2. Install the ruby dependencies
bundle install
```

### Running the app

You can run the server via `rackup`:

```bash
bundle exec rackup
```

This will start the server on `localhost:9292`

## Configuration and deployment

TODO: Add these details once we've got our deployment running.

## Explain how to test the project

```bash
# Run the Ruby test suite
bundle exec rspec
```

## Support

Raise a Github issue if you need support.

## Explain how users can contribute

We welcome contributions - please read [CONTRIBUTING.md](CONTRIBUTING.md) and the [alphagov Code of Conduct](https://github.com/alphagov/.github/blob/main/CODE_OF_CONDUCT.md) before contributing.

## License

We use the [MIT License](https://opensource.org/licenses/MIT).