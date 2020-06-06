# https://github.com/18F/jekyll-oembed/blob/master/lib/jekyll_oembed.rb
# Updated and improved with caching and some other tweaks
require 'oembed'

streamableOEmbed = OEmbed::Provider.new("https://api.streamable.com/oembed.{format}")
streamableOEmbed << "http://www.streamable.com/*"
streamableOEmbed << "http://streamable.com/*"
streamableOEmbed << "https://www.streamable.com/*"
streamableOEmbed << "https://streamable.com/*"

redditOEmbed = OEmbed::Provider.new("https://www.reddit.com/oembed")
redditOEmbed << "http://www.reddit.com/r/*/comments/*/*"
redditOEmbed << "http://reddit.com/r/*/comments/*/*"
redditOEmbed << "https://www.reddit.com/r/*/comments/*/*"
redditOEmbed << "https://reddit.com/r/*/comments/*/*"

# Register all default OEmbed providers
OEmbed::Providers.register_all
# Since register_all does not register all default providers,
# we need to do this here.
# See https://github.com/judofyr/ruby-oembed/issues/18
OEmbed::Providers.register(
    streamableOEmbed, redditOEmbed,
    ::OEmbed::Providers::Instagram,
    ::OEmbed::Providers::Slideshare,
    ::OEmbed::Providers::Yfrog,
    ::OEmbed::Providers::MlgTv
)

module Jekyll
  # "Borrowed" from
  # https://github.com/rob-murray/jekyll-twitter-plugin/blob/master/lib/jekyll-twitter-plugin.rb
  class FileCache
    def initialize(path)
      @cache_folder = File.expand_path path
      FileUtils.mkdir_p @cache_folder
    end

    def read(key)
      file_to_read = cache_file(Digest::SHA2.new(256).hexdigest key)
      File.read(file_to_read) if File.exist?(file_to_read)
    end

    def write(key, response)
      file_to_write = cache_file(Digest::SHA2.new(256).hexdigest key)

      File.open(file_to_write, "w") do |f|
        f.write(response.html)
      end
    end

    private

    def cache_file(key)
      File.join(@cache_folder, cache_filename(key))
    end

    def cache_filename(cache_key)
      "#{cache_key}.cache"
    end
  end

  class OEmbedPlugin < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @text = text
    end

    def cache
      @cache ||= FileCache.new("./.embed-cache")
    end

    def render(context)
      # Pipe param through liquid to make additional replacements possible
      url = Liquid::Template.parse(@text).render context
      url = url.strip! || url.strip
      begin
        html_output(cached_embed(url) || live_embed(url))
      rescue Exception => e
        error_message(e, url)
        ''
      end
    end

    def live_embed(url)
      puts "Embedding from API: #{url}".yellow
      result = ::OEmbed::Providers.get(url)
      cache.write(url, result)
      result.html
    end

    def cached_embed(url)
      result = cache.read(url)
      if result
        puts "Embedding from cache: #{url}".green
        return result
      else
        return nil
      end
    end

    def html_output(html)
      "<div class=\"embed-container\">#{html}</div>"
    end

    def error_message(e, url)
      # Silent error. This seems preferable to a hard fail
      # because a user could make a URL private anytime.
      puts "OEmbed Error: #{e}".red
    end
  end
end

Liquid::Template.register_tag('oembed', Jekyll::OEmbedPlugin)

