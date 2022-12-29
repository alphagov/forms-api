.PHONY: setup serve test lint lint-fix db db-down

setup:
	bin/setup

serve: setup
	bin/rails server

test: setup
	bundle exec rspec

# test-watch: setup
# 	bundle exec guard -i --notify false -P rspec

lint:
	bundle exec rubocop
	bundle exec bundle-audit check

lint-fix:
	bundle exec rubocop -A
db:
	docker-compose up -d
clean:
	docker-compose down
