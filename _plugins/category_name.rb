module Jekyll
  module CategoryNameFilter
    SPECIAL_CASES = { 'ai' => 'AI', 'diy' => 'DIY' }.freeze

    def category_name(input, requested_locale = nil)
      text = input.to_s.strip
      site = @context.registers[:site]
      page = @context.registers[:page]
      page_locale = if page.respond_to?(:[])
                      page['locale']
                    elsif page.respond_to?(:data)
                      page.data['locale']
                    end
      locale = requested_locale || page_locale
      description = Array(site.config['descriptions']).find do |item|
        item['cat'].to_s == text && item['locale'].to_s == locale.to_s
      end
      return description['display'] if description && description['display']

      SPECIAL_CASES.fetch(text.downcase, text.capitalize)
    end
  end
end

Liquid::Template.register_filter(Jekyll::CategoryNameFilter)
