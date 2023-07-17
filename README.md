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
./bin/setup
```

### Running the app

```bash
# Running the server without watching for changes
bundle exec rails s
```

This will start the server on `localhost:9292`

### Testing the project

```bash
# Run the Ruby test suite
bundle exec rake
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

## Logging

- HTTP access logs are managed using [Lograge](https://github.com/roidrage/lograge) and configured within [the application config](./config/application.rb)
- The output format is JSON using the [JsonLogFormatter](./app/lib/json_log_formatter.rb) to enable simpler searching and visbility especially in Splunk.
- **DO NOT** use [log_tags](https://guides.rubyonrails.org/configuring.html#config-log-tags) since it breaks the JSON formatting produced by Lograge.


## Updating versions

Use the [update_app_versions.sh script in forms-deploy](https://github.com/alphagov/forms-deploy/blob/main/support/update_app_versions.sh)

## Support

Raise a Github issue if you need support.

## How to contribute

We welcome contributions - please read [CONTRIBUTING.md](CONTRIBUTING.md) and the [alphagov Code of Conduct](https://github.com/alphagov/.github/blob/main/CODE_OF_CONDUCT.md) before contributing.

## License

We use the [MIT License](https://opensource.org/licenses/MIT).


