install:
	bundle install

server:
	bin/rails server

format:
	bundle exec rubocop -A
