![build status badge](https://github.com/alphagov/forms-api/actions/workflows/deploy.yml/badge.svg)
![tests status](https://github.com/alphagov/forms-api/actions/workflows/ruby.yml/badge.svg)

# GOV.UK Forms - API

`forms-api` is the API for the GOV.UK Forms platform. It is a Ruby on Rails api app, currently using a Postgresql database for data storage and is used for storing/serving the form configurations that are created by form creators in [forms-admin](https://github.com/alphagov/forms-admin).

## Before you start

To run the project you will need to install:

- [Ruby](https://www.ruby-lang.org/en/) - we use version 3.1 of Ruby. Before running the project, double check the [.ruby-version] file to see the exact version.
- a running [PostgreSQL](https://www.postgresql.org/) database

We recommend using a version manager to install and manage these, such as:

- [asdf](https://github.com/asdf-vm/asdf) for Ruby (and many other languages)
- [RVM](https://rvm.io/) or [rbenv](https://github.com/rbenv/rbenv) for Ruby


## Getting started

### Installing for the first time

```bash
# 1. Clone the git repository and change directory to the new folder
git clone git@github.com:alphagov/forms-api.git
cd forms-api

# 2. Run the setup command
make setup
```

`make setup` runs `bin/setup` which is idempotent, so you can also run it whenever you pull new changes.

### Running the app

You can run the server via `make serve`

```bash
# Running the server without watching for changes
make serve
```

`make serve` runs `bin/setup`which is idempotent, followed by `bin/rails server`

This will start the server on `localhost:9292`


### Testing the project

```bash
# Run the Ruby test suite
make test
```

### To run the linter

```bash
# Run rubocop and display errors
make lint

# Run rubocop with fixes and display errors
make lint-fix
```

## Secrets vs Settings

Refer to the [the config gem](https://github.com/railsconfig/config#accessing-the-settings-object) to understand the `file based settings` loading order.

To override file based via `Machine based env variables settings`

```bash
cat config/settings.yml
file
  based
    settings
      env1: 'foo'
```

```bash
export SETTINGS__FILE__BASED__SETTINGS__ENV1="bar"
```

```ruby
puts Settings.file.based.setting.env1
bar
```

Refer to the [settings file](config/settings.yml) for all the settings required to run this app

## Feature flags

This repo supports the ability to set up feature flags. To do this, add your feature flag in the [settings file](config/settings.yml) under the `features` property. eg:

```yaml
features:
  some_feature: true
```

You can then use the [feature service](app/services/feature_service.rb) to check whether the feature is enabled or not. Eg. `FeatureService.enabled?(:some_feature)`.

You can also nest features:

```yaml
features:
  some:
    nested_feature: true
```

And check with `FeatureService.enabled?("some.nested_feature")`.

### Testing with features

Rspec tests can also be tagged with `feature_{name}: true`. This will turn that feature on just for the duration of that test.

## Support

Raise a Github issue if you need support.

## How to contribute

We welcome contributions - please read [CONTRIBUTING.md](CONTRIBUTING.md) and the [alphagov Code of Conduct](https://github.com/alphagov/.github/blob/main/CODE_OF_CONDUCT.md) before contributing.

## License

We use the [MIT License](https://opensource.org/licenses/MIT).
