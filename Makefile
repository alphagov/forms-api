.PHONY: setup
setup:
	bundle install

.PHONY: serve
serve: setup
	bundle exec rackup

.PHONY: serve-watch
serve-watch: setup
	bundle exec guard -i --notify false -P rack

.PHONY: test
test: setup
	bundle exec rspec

.PHONY: test watch
test-watch: setup
	bundle exec guard -i --notify false -P rspec
