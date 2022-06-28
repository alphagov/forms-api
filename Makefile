.PHONY: serve
serve:
	bundle exec rackup

.PHONY: test
test:
	bundle exec rspec

.PHONY: setup
setup:
	bundle install
