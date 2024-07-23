HOST ?= 127.0.0.1

deps:
	bundle install

serve:
	bundle exec jekyll serve --host $(HOST)
