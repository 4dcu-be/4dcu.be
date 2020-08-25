Jekyll::Hooks.register :posts, :pre_render do |post, payload|
  post.content.gsub!(/^!\[(.*)\]\(([^\)]+)\)((?:{:[^}]+})*)/, "<a href=\"{{ site.baseurl }}\\2\" class=\"lightgallery-link\" data-sub-html=\"\\1\">\n![\\1]({{ site.baseurl }}\\2)\\3{:data-src=\"{{ site.baseurl }}\\2\" loading=\"lazy\"}\n</a>")
end
