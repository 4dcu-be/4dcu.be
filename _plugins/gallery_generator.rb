require "mini_magick"
include MiniMagick

module Jekyll
  class GalleryGenerator < Generator
    safe true

    def generate(site)
       posts = site.posts.docs.select { |post| post.data['gallery_items'] }
       resize_dimensions = Jekyll.configuration({})['gallery_items']['resize_dimensions']
       crop_dimensions = Jekyll.configuration({})['gallery_items']['crop_dimensions']
       posts.each do |post|
         post.data['gallery_items'].each do |item|
             input_path = ".#{item['image']}"
             output_path = ".#{item['gallery_image']}"
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
end
