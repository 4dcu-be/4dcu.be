# Jekyll re-copies every static file on each fresh `jekyll build` because its
# "modified?" check uses an in-memory table that starts empty. Compare with the
# file already in the destination instead: copy_file stamps the copy with the
# source mtime, so an unchanged file matches on mtime and size.
module Jekyll
  class StaticFile
    alias_method :__write_always, :write

    def write(dest)
      dest_path = destination(dest)
      if File.exist?(dest_path) &&
         File.mtime(dest_path).to_i == mtime &&
         File.size(dest_path) == File.size(path)
        self.class.mtimes[path] = mtime
        return false
      end
      __write_always(dest)
    end
  end
end
