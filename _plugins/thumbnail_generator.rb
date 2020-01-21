require "mini_magick"
include MiniMagick

module Jekyll
  class ThumbnailGenerator < Generator
    safe true

    def generate(site)
       posts = site.posts.docs.select { |post| post.data['thumbnail'] }
       resize_dimensions = Jekyll.configuration({})['thumbnail']['resize_dimensions']
       crop_dimensions = Jekyll.configuration({})['thumbnail']['crop_dimensions']
       posts.each do |post|
         input_path = ".#{post['cover']}"
         output_path = ".#{post['thumbnail']}"
         if !File.exists?(output_path) || File.mtime(output_path) <= File.mtime(input_path)
            puts("Generating thumbnail", input_path, output_path)
            image = MiniMagick::Image.open(input_path)
            image.strip
            image.compress "JPEG2000"
            image.resize resize_dimensions
            image.gravity "center"
            image.crop crop_dimensions
            image.write output_path
         end
      end
    end
  end
end
