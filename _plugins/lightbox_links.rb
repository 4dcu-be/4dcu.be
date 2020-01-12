Jekyll::Hooks.register :posts, :pre_render do |post, payload|
  docExt = post.extname.tr('.', '')
  post.content.gsub!(/!\[(.*)\]\(([^\)]+)\)(?:{:([^}]+)})*/, "<a href=\"\\2\" data-lightbox=\"blog\" data-title=\"\\1\">\n<img src=\"\\2\" alt=\"\\1\" />\n</a>")
end
