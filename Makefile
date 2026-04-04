HOST ?= 127.0.0.1

build: clean
	bundle exec jekyll build

clean:
	rm -rf _site/

deploy: build
	npx wrangler deploy

deps:
	bundle install

serve:
	bundle exec jekyll serve --host $(HOST)

staging: build
	npx wrangler versions upload --preview-alias staging
