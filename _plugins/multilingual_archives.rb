module Jekyll
  class LocalizedArchivePage < Page
    def initialize(site, base, language, type, key, posts)
      @site = site
      @base = base
      prefix = language['index'].to_s.sub(%r{^/}, '').sub(%r{/$}, '')
      segment = type == 'year' ? 'year' : type
      @dir = File.join(prefix, segment, key.to_s)
      @name = 'index.html'

      process(@name)
      read_yaml(File.join(base, '_layouts'), 'archive.html')

      locale = language['locale']
      strings = (site.data['translations'] || {})[locale] || {}
      label = key.to_s
      label = label.capitalize unless type == 'year'

      data['locale'] = locale
      data['type'] = type
      data['title'] = label
      data['posts'] = posts.sort_by(&:date).reverse
      data['post_id'] = "#{type}_#{key}"
      data['sitemap'] = type == 'category'
      data['noindex'] = type != 'category'

      description_key = "#{type == 'year' ? 'archive' : type}_description"
      description = strings[description_key]
      if description
        data['description'] = description
          .gsub('%{year}', key.to_s)
          .gsub('%{category}', label)
          .gsub('%{tag}', label)
      end

      data['date'] = Time.new(key.to_i, 1, 1) if type == 'year'
    end
  end

  class MultilingualArchiveGenerator < Generator
    safe true
    priority :low

    def generate(site)
      languages = site.config['languages'] || []
      return if languages.empty? || !site.layouts.key?('archive')

      posts_by_locale = site.posts.docs.group_by { |post| post.data['locale'] }
      languages.each do |language|
        posts = posts_by_locale.fetch(language['locale'], [])
        generate_group(site, language, 'year', posts.group_by { |post| post.date.year.to_s })
        generate_group(site, language, 'category', group_terms(posts, 'categories'))
        generate_group(site, language, 'tag', group_terms(posts, 'tags'))
        add_local_navigation(posts)
      end
    end

    private

    def group_terms(posts, field)
      posts.each_with_object({}) do |post, groups|
        Array(post.data[field]).each do |term|
          slug = Jekyll::Utils.slugify(term.to_s)
          (groups[slug] ||= []) << post
        end
      end
    end

    def generate_group(site, language, type, groups)
      groups.each do |key, posts|
        site.pages << LocalizedArchivePage.new(site, site.source, language, type, key, posts)
      end
    end

    def add_local_navigation(posts)
      ordered = posts.sort_by(&:date)
      ordered.each_with_index do |post, index|
        post.data['previous_in_locale'] = ordered[index - 1] if index.positive?
        post.data['next_in_locale'] = ordered[index + 1] if index < ordered.length - 1
      end
    end
  end
end
