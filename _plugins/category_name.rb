module Jekyll
  module CategoryNameFilter
    SPECIAL_CASES = {
      "ai" => "AI",
      "diy" => "DIY",
    }.freeze

    def category_name(input)
      text = input.to_s.strip
      SPECIAL_CASES.fetch(text.downcase, text.capitalize)
    end
  end
end

Liquid::Template.register_filter(Jekyll::CategoryNameFilter)
