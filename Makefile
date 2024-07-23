BRANCH ?= staging
HOST ?= 127.0.0.1

build:
	bundle exec jekyll build

clean:
	rm -rf _site/

deploy:
	npx wrangler pages deploy --branch $(BRANCH) --project-name myhro-blog _site/

deps:
	bundle install

serve:
	bundle exec jekyll serve --host $(HOST)
