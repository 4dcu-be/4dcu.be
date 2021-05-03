Jekyll::Hooks.register :posts, :pre_render do |post, payload|
  post.content.gsub!(/^\[!\[(.*)\]\(([^\)]+)\)\]\(([^\)]+)\)/, "<vegachart schema-url=\"{{ site.baseurl }}\\3\" style=\"width: 100%\"></vegachart>")
end
