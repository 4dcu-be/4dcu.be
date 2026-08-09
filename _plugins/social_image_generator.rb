require "mini_magick"

# Generates 1200x630 JPEGs for Open Graph and Twitter cards from post covers.
# The generated path is exposed as page.social_image. A site-wide fallback is
# generated from site.cover and exposed as site.social_image.default.
module Jekyll
  class SocialImageGenerator < Generator
    safe true
    priority :low

    DEFAULTS = {
      "dir"     => "/assets/social",
      "width"   => 1200,
      "height"  => 630,
      "quality" => 82,
    }.freeze

    def generate(site)
      @site    = site
      @config  = DEFAULTS.merge(site.config["social_image"] || {})
      @source  = site.source
      @emitted = {}

      site.posts.docs.each do |post|
        next unless post.data["cover"]

        card = card_for(post.data["cover"])
        post.data["social_image"] = card if card
      end

      if site.config["cover"]
        default_card = card_for(site.config["cover"], "site-default")
        if default_card
          site.config["social_image"] = @config.merge("default" => default_card)
        end
      end
    end

    private

    def card_for(cover, name = nil)
      name ||= card_name(cover)
      rel = File.join(@config["dir"], "#{name}.jpg")
      return @emitted[rel] if @emitted.key?(rel)

      input = File.join(@source, cover)
      output = File.join(@source, rel)

      unless File.exist?(input)
        Jekyll.logger.warn "SocialImage:", "cover not found, skipping: #{cover}"
        return @emitted[rel] = nil
      end

      render(input, output) if stale?(input, output)
      register(rel)

      @emitted[rel] = rel
    end

    def stale?(input, output)
      !File.exist?(output) || File.mtime(output) <= File.mtime(input)
    end

    def render(input, output)
      Jekyll.logger.info "SocialImage:", "generating #{output}"
      FileUtils.mkdir_p(File.dirname(output))

      geometry = "#{@config['width']}x#{@config['height']}"
      image = MiniMagick::Image.open(input)
      image.combine_options do |img|
        img.strip
        img.auto_orient
        img.resize "#{geometry}^"
        img.gravity "center"
        img.extent "#{geometry}+0+0"
        img.quality @config["quality"].to_s
        img.interlace "Plane"
      end
      image.format "jpg"
      image.write output
    end

    # Jekyll discovers static files before generators run. Register generated
    # cards explicitly so a clean build copies them to the destination.
    def register(rel)
      return if @site.static_files.any? { |file| file.relative_path == rel }

      dir = File.dirname(rel)
      base = File.basename(rel)
      @site.static_files << Jekyll::StaticFile.new(@site, @source, dir, base)
    end

    def card_name(cover)
      cover.sub(%r{\A/?assets/}, "")
           .sub(/\.[^.\/]+\z/, "")
           .gsub(%r{[/\s]+}, "-")
           .gsub(/[^A-Za-z0-9._-]/, "")
    end
  end
end
