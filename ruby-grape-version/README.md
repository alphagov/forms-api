![build status badge](https://github.com/alphagov/forms-api/actions/workflows/deploy.yml/badge.svg)
![tests status](https://github.com/alphagov/forms-api/actions/workflows/ruby.yml/badge.svg)

# GOV.UK Forms - API

`forms-api` is the API for the GOV.UK Forms platform. It is a Ruby application that is built using Sinatra, currently using a Postgresql database for data storage and is used for storing/serving the form configurations that are created by form creators.

Dev server url: https://forms-api-dev.london.cloudapps.digital/api/v1/forms/

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

# 2. Run the setup command
make setup
```

### Running the app

You can run the server via `make serve` or `make serve-watch` to re-run on changes:

```bash
# Running the server without watching for changes
make serve

# Running the server watching for changes
make serve-watch
```

This will start the server on `localhost:9292`

## Configuration and deployment

### Environment variables

Environment variables can be set using `.env` and `.env.development`/`env.test` for environment specific variables.

| Name | Purpose |
| ------------- | ------------- |
| `DATABASE_URL` | The URL to the postgres database|
| `API_KEY` | The API key for authentication |

TODO: Add these details once we've got our deployment running.

## Explain how to test the project

```bash
# Run the Ruby test suite
make test

# Run the Ruby test re-running on changes
make test-watch
```

## To run the linter

```bash
# Run rubocop and display errors
make lint

# Run rubocop with fixes and display errors
make lint-fix
```

## Support

Raise a Github issue if you need support.

## Explain how users can contribute

We welcome contributions - please read [CONTRIBUTING.md](CONTRIBUTING.md) and the [alphagov Code of Conduct](https://github.com/alphagov/.github/blob/main/CODE_OF_CONDUCT.md) before contributing.

## License

We use the [MIT License](https://opensource.org/licenses/MIT).
