Jekyll::Hooks.register :posts, :pre_render do |post, payload|
  post.content.gsub!(
    /^!\[(.*?)\]\(([^\s\)]+)(?:\s+"([^"]*)")?\)((?:\{:[^}]+\})*)/
  ) do
    alt, url, caption, ial = $1, $2, $3, $4
    base = "{{ site.baseurl }}#{url}"
    sub_html = (caption && !caption.empty?) ? caption : alt
    link = %(<a href="#{base}" class="lightgallery-link" data-sub-html="#{sub_html}">\n) +
           %(![#{alt}](#{base})#{ial}{:data-src="#{base}" loading="lazy"}\n</a>)

    if caption && !caption.empty?
      size_class = ial[/\{:\.(\S+?)\}/, 1]
      figure_cls = ["captioned-image", size_class].compact.join(" ")
      %(<figure class="#{figure_cls}" markdown="1">\n#{link}\n<figcaption>#{caption}</figcaption>\n</figure>)
    else
      link
    end
  end
end
