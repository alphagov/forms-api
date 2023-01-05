.PHONY: setup serve test lint lint-fix

setup:
	bin/setup

serve: setup
	bin/rails server

test: setup
	bundle exec rspec

lint:
	bundle exec rubocop
	bundle exec bundle-audit check

lint-fix:
	bundle exec rubocop -A
