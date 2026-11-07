require 'fastimage'

# Adds width/height to markdown images.
#
# Reading every image header cost ~3.5 s per build, so sizes are cached in a
# single file in the cache dir (one read and one write per build; Jekyll::Cache
# would use one file per image, which is just as slow on a mounted drive).
# Entries are keyed by path and checked against mtime and size, and each image
# is checked once per build even when several posts use it.
module ImageSizeCache
  module_function

  def setup(site)
    @file = File.join(site.in_source_dir(site.config['cache_dir'] || '.jekyll-cache'), 'image_sizes.marshal')
    @persist = !site.config['disable_disk_cache'] && !site.safe
    @entries ||= begin
      @persist && File.exist?(@file) ? Marshal.load(File.binread(@file)) : {}
    rescue StandardError
      {}
    end
    @seen = {}
    @dirty = false
  end

  def size(path)
    return @seen[path] if @seen.key?(path)

    @seen[path] = begin
      stat = File.stat(path)
      entry = @entries[path]
      if entry.nil? || entry[0] != stat.mtime.to_i || entry[1] != stat.size
        entry = [stat.mtime.to_i, stat.size, FastImage.size(path)]
        @entries[path] = entry
        @dirty = true
      end
      entry[2]
    rescue Errno::ENOENT
      nil
    end
  end

  def save
    return unless @persist && @dirty

    FileUtils.mkdir_p(File.dirname(@file))
    File.binwrite(@file, Marshal.dump(@entries))
    @dirty = false
  end
end

Jekyll::Hooks.register :site, :pre_render do |site|
  ImageSizeCache.setup(site)
end

Jekyll::Hooks.register :site, :post_write do |_site|
  ImageSizeCache.save
end

Jekyll::Hooks.register :documents, :pre_render, priority: 1 do |page|
    page.content = page.content.gsub(/\!\[(.*?)\]\({{ site.baseurl }}(.*?)\)/) do |match|
        width, height = ImageSizeCache.size("#{Jekyll.sites.first.source}#{$2}")
        output = "![#{$1}]({{ site.baseurl }}#{$2}){: height=\"#{height}\" width=\"#{width}\"}"
        output
    end
end
