Jekyll::Hooks.register :posts, :pre_render do |post, payload|
  docExt = post.extname.tr('.', '')
  post.content.gsub!(/!\[(.*)\]\(([^\)]+)\)((?:{:[^}]+})*)/, "<a href=\"{{ site.baseurl }}\\2\" class=\"lightgallery-link\" data-sub-html=\"\\1\">\n![\\1](\\2)\\3{:data-src=\"\\2\"}\n</a>")
end
