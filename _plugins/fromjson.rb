require 'net/http'

module Jekyll
    class JsonPageGenerator < Generator
        safe true

        def generate(site)
            i = 0
            site.data['report_pages'] = []

            json = JSON.parse(Net::HTTP.get(URI('https://raw.githubusercontent.com/2020PB/police-brutality/data_build/all-locations.json')))
            for data in json['data']
                i += 1
				page_name = Utils::slugify(data['name'])
                page = PageWithoutAFile.new(site, __dir__, "report", "#{page_name}.html")

				page.data.merge!(data)
				page.data.merge!(
					"title" => data['name'],
					"exclude" => true,
					"layout" => 'report'
				)

                # If there is a streamable link, embed that, otherwise embed a
                # reddit link, or a twitter link, etc.
                process_embeds(page, 'streamable.com') ||
                    process_embeds(page, 'reddit.com') ||
                    process_embeds(page, 'twitter.com') ||
                    process_embeds(page, 'instagram.com')

                site.pages << page
                site.data['report_pages'] << page
            end
        end

        # Process links in a page and create an embed for a particular website
        def process_embeds(page, match)
            for link in page.data['links']
                if link.include? match
                    page.data.merge!('embed_link' => link)
                    return true
                end
            end
            return false
        end
    end
end
