require 'json'

module Jekyll

  class JSONFeaturedGenerator < Generator
    safe true

    def generate(site)

      # featured.json is committed and written into the source folder, so it
      # always uses the production url from _config.yml, even when serving
      # with _config_dev.yml. Read that file once rather than per post.
      prod_config = SafeYAML.load_file(File.join(site.source, '_config.yml'))
      base_url = prod_config['url'].to_s + prod_config['baseurl'].to_s

      output = []

      site.posts.docs.reverse[0..3].each do |post|
        output.append({
            "title": post.data["title"],
            "categories": post.data["categories"],
            "thumbnail": base_url + post.data["thumbnail"]
        })
      end

      path = 'featured.json'

      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') do |f|
        f.write(output.to_json)
      end
    end

  end

end
