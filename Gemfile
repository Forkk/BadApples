source "https://rubygems.org"

gem "jekyll", "~> 4.1.0"

gem "minima", "~> 2.5"

# For plugins later
group :jekyll_plugins do
end

# Necessary for the oembed plugin in the `_plugins` dir
gem 'ruby-oembed'

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", "~> 1.2"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", "~> 0.1.1", :platforms => [:mingw, :x64_mingw, :mswin]

