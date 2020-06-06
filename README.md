# Police Brutality Catalog

This website displays instances of police brutality in America that have been
recorded by the people and catalogued by the [2020 Police
Brutality](https://github.com/2020PB/police-brutality/) organization on GitHub.


# Building

This website is a simple static site built using Jekyll. You only need to
install Ruby's `bundler` package manager manually.

To build the site, simply run `bundle install` to install dependencies, and
then run `bundle exec jekyll build` to build the site to the `_site` directory.

If you'd like to make changes to the website, you can run `bundle exec jekyll
serve`. This will start a web server, which will host the website on
`localhost:4000` and automatically rebuild after any changes (except changes to
`_config.yml` and plugins)

