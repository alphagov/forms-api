run: test
	bundle exec rackup
test: lint
	bundle exec rspec
lint:
	bundle exec rubocop -A
setup:
	bundle install
	docker-compose up -d
clean:
	docker-compose down