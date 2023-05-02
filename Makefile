install:
	bundle install

console:
	bin/rails console

# list all routes
routes:
	bin/rails routes

server:
	bin/rails server --binding=0.0.0.0

# format all code
format:
	bundle exec rubocop -A
