require 'fastimage'

Jekyll::Hooks.register :documents, :pre_render, priority: 1 do |page|
    page.content = page.content.gsub(/\!\[(.*?)\]\({{ site.baseurl }}(.*?)\)/) do |match|
        # puts("#{Jekyll.sites.first.source}#{$2}")
        width, height = FastImage.size("#{Jekyll.sites.first.source}#{$2}")
        output = "![#{$1}]({{ site.baseurl }}#{$2}){: height=\"#{height}\" width=\"#{width}\"}"
        # puts(output)
        output
    end
end
