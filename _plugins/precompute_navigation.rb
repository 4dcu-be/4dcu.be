# Precomputes, once per build, what nav_links.html, nav_links_footer.html and
# alternates.html used to derive by looping over site.pages / site.posts on
# every page render (about 26 s of a 54 s build).
#
#   site.data['nav'][locale]   -> [{ 'title' => ..., 'url' => ... }, ...]
#   page.alternates            -> ["<locale>~<canonical url>", ...]
#   page.alternates_fallback   -> same, but falls back to the language index
#                                 (alternates.html with fallback_to_index=true)
module Jekyll
  module PrecomputeNavigation
    module_function

    # Same rule as _includes/canonical_url.html.
    def canonical(url)
      url.size > 10 && url.end_with?('index.html') ? url[0...-10] : url
    end

    def run(site)
      languages = site.config['languages'] || []
      default_locale = languages.dig(0, 'locale')
      language_indexes = languages.map { |lang| lang['index'] }

      # Main navigation, in site.pages order. Pages without an explicit or
      # default locale never match (same as the old Liquid condition).
      nav = Hash.new { |h, k| h[k] = [] }
      site.pages.each do |p|
        next unless p.data['title'] && p.data['main_nav'] == true

        nav[p.data['locale']] << { 'title' => p.data['title'], 'url' => p.url }
      end
      site.data['nav'] = nav

      # post_id -> locale -> url. Posts newest first (the order of site.posts
      # in Liquid), then pages; the last match wins, as in the old loops.
      posts = site.posts.docs.sort { |a, b| b <=> a }
      by_id = Hash.new { |h, k| h[k] = {} }
      (posts + site.pages).each do |item|
        id = item.data['post_id']
        by_id[id][item.data['locale']] = item.url if id
      end

      (site.posts.docs + site.pages).each do |item|
        id = item.data['post_id']
        url = item.url
        locale = item.data['locale'] || default_locale
        is_language_index = language_indexes.include?(url)

        strict = []
        fallback = []
        languages.each do |lang|
          found =
            if id
              by_id[id][lang['locale']]
            elsif is_language_index
              lang['index']
            elsif lang['locale'] == locale
              url
            end
          found = nil if found.to_s.empty?

          strict << "#{lang['locale']}~#{canonical(found)}" if found
          found ||= lang['index']
          fallback << "#{lang['locale']}~#{canonical(found)}" unless found.to_s.empty?
        end
        item.data['alternates'] = strict
        item.data['alternates_fallback'] = fallback
      end
    end
  end

  # Runs after all generators, so archive and pagination pages are included.
  Hooks.register :site, :pre_render do |site|
    PrecomputeNavigation.run(site)
  end
end
