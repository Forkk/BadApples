require 'net/http'

module Jekyll
    class JsonPageGenerator < Generator
        safe true

        def generate(site)
            site.data['source_data'] = JSON.parse(Net::HTTP.get(URI('https://raw.githubusercontent.com/2020PB/police-brutality/data_build/all-locations.json')))

            generate_reports(site)
            generate_states(site)
            generate_cities(site)
        end

        # Generate pages for browsing incidents by city.
        def generate_cities(site)
            cities = {}
            for page in site.data['report_pages']
                key = "#{page['state']}-#{page['city']}"
                if !cities.has_key?(key)
                    cities[key] = []
                end
                cities[key] << page
            end

            site.data['city_pages'] = []
            site.data['city_pages_by_state'] = {}
            for key in cities.keys
                sample = cities[key][0]
                page = PageWithoutAFile.new(site, __dir__, "city", "#{key.downcase}.html")

                page.data.merge!(
                    "title" => "#{sample['city']}, #{sample['state']}",
                    "state" => sample['state'],
                    "city" => sample['city'],
                    "layout" => 'city',
                    "reports" => cities[key]
                )

                site.pages << page
                site.data['city_pages'] << page

                if !site.data['city_pages_by_state'].has_key?(sample['state'])
                    site.data['city_pages_by_state'][sample['state']] = []
                end
                site.data['city_pages_by_state'][sample['state']] << page
            end

            site.data['city_pages'].sort! do |a, b|
                a['title'] <=> b['title']
            end
        end

        # Generate pages for browsing incidents by state.
        def generate_states(site)
            states = {}
            for page in site.data['report_pages']
                if !states.has_key?(page['state'])
                    states[page['state']] = []
                end
                states[page['state']] << page
            end

            site.data['state_pages'] = []
            for name in states.keys
                page = PageWithoutAFile.new(site, __dir__, "state", "#{name.downcase}.html")

                page.data.merge!(
                    "title" => name,
                    "exclude" => true,
                    "layout" => 'state',
                    "reports" => states[name]
                )

                site.pages << page
                site.data['state_pages'] << page
            end
            site.data['state_pages'].sort! do |a, b|
                a['title'] <=> b['title']
            end
        end

        # Generate individual pages for each report.
        def generate_reports(site)
            site.data['report_pages'] = []

            i = 0
            for data in site.data['source_data']['data']
                i += 1
                page_name = data['id']
                if page_name.nil? || page_name.empty?
                    puts "Report has no ID: #{data}".red
                    page_name = i.to_s
                end
                page = PageWithoutAFile.new(site, __dir__, "report", "#{page_name}.html")

                # Process links in the data to change `old.reddit.com` links to
                # new reddit links. This is both for consistency, and to fix
                # oembeds, which don't work with `old.reddit.com` links.
                data['links'].map! do |link|
                    if link.include?('old.reddit.com')
                        link.sub 'old.reddit.com', 'www.reddit.com'
                    else
                        link
                    end
                end

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

            # Sort report pages by state so that all reports from a single
            # state appear next to each other.
            site.data['report_pages'].sort! do |a, b|
                a['state'] <=> b['state']
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
