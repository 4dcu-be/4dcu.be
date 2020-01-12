Jekyll::Hooks.register :posts, :pre_render do |post, payload|
  docExt = post.extname.tr('.', '')
  post.content.gsub!(/!\[(.*)\]\(([^\)]+)\)((?:{:[^}]+})*)/, "<a href=\"{{ site.baseurl }}\\2\" data-lightbox=\"blog\" data-title=\"\\1\">\n![\\1](\\2)\\3\n</a>")
end
