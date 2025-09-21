# Jekyll plugin to copy static files without processing
module Jekyll
  class StaticFilesGenerator < Generator
    safe true
    priority :low

    def generate(site)
      static_dir = File.join(site.source, 'static_files')
      return unless Dir.exist?(static_dir)

      # Copy all files from static_files directory to _site without processing
      Dir.glob(File.join(static_dir, '**', '*')).each do |file_path|
        next if File.directory?(file_path)
        
        # Get relative path from static_files directory
        relative_path = file_path.sub(static_dir + '/', '')
        destination = File.join(site.dest, 'static_files', relative_path)
        
        # Create destination directory if it doesn't exist
        FileUtils.mkdir_p(File.dirname(destination))
        
        # Copy file without processing
        FileUtils.cp(file_path, destination)
        
        Jekyll.logger.info "Static file copied: #{relative_path}"
      end
    end
  end
end
