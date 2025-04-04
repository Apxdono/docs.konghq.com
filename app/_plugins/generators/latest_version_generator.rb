# frozen_string_literal: true

module Jekyll
  # Add a way to change the page URL
  class Page
    attr_writer :url
  end
end

module LatestVersion
  class Generator < Jekyll::Generator
    priority :medium
    def generate(site) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
      products_with_latest = %w[gateway mesh KIC deck]

      @page_index = site.config['defaults'].to_h do |s|
        next [s['scope']['path'], s['values']['version-index']]
      end

      # Load config file
      site.pages.each do |page|
        page_path = remove_generated_prefix(page.path)
        parts = Pathname(page_path).each_filename.to_a

        products_with_latest.each do |product|
          # Reset values for every new page
          generate_latest = false
          release_path = nil

          product_name = product.downcase
          # Special case KIC
          product_name = 'kubernetes-ingress-controller' if product_name == 'kic'

          # Latest version
          if parts[0] == product_name && parts[1] == site.data["kong_latest_#{product}"]['release']
            generate_latest = true
            release_path = parts[1]
          end

          next unless generate_latest && !page.data['is_latest']
          # If it has a permalink it's _probably_ an index page e.g. /gateway/
          # so we should not generate a /latest/ URL as it's already evergreen
          next if page.data['permalink']

          # Otherwise, let's generate a /latest/ URL too
          page = DuplicatePage.new(
            site,
            site.source,
            page.url.gsub(release_path, 'latest'),
            page.content,
            page.data,
            @page_index["#{product_name}/#{release_path}/"],
            page_path
          )
          site.pages << page
        end
      end
    end

    def remove_generated_prefix(path)
      # Remove the generated prefix if it's present
      # It's in the format GENERATED:nav=nav/product_1.2.x:src=src/path/here:/output/path
      return path unless path.start_with?('GENERATED:')

      path = path.split(':')
      path.shift(3)
      path.join(':')
    end
  end

  class DuplicatePage < ::Jekyll::Page
    def initialize(site, base_dir, url, content, data, page_index, path) # rubocop:disable Lint/MissingSuper, Metrics/ParameterLists, Metrics/MethodLength
      @site = site
      @base = base_dir
      @content = content

      @dir = url
      @name = 'index.md'

      process(@name)
      @data = data.clone
      @data['is_latest'] = true
      @data['version-index'] = page_index
      @data['edit_link'] = "app/#{path}" unless @data['edit_link']

      @data['alias'] = [@dir.sub('latest/', '')] if @dir.end_with?('/latest/')
    end
  end
end
