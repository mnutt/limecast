# Note: this is in Rails trunk (http://github.com/rails/rails/commit/51d7b3070c68492f5376c19d24d8e5a2d746d7ea)
module ActionView
  module Helpers
    module AssetTagHelper
     # Computes the path to a video asset in the public videos directory.
     # Full paths from the document root will be passed through.
     # Used internally by +video_tag+ to build the video path.
     #
     # ==== Examples
     #   video_path("hd")                                            # => /videos/hd
     #   video_path("hd.avi")                                        # => /videos/hd.avi
     #   video_path("trailers/hd.avi")                               # => /videos/trailers/hd.avi
     #   video_path("/trailers/hd.avi")                              # => /videos/hd.avi
     #   video_path("http://www.railsapplication.com/vid/hd.avi") # => http://www.railsapplication.com/vid/hd.avi
     def video_path(source)
       compute_public_path(source, 'videos')
     end
     alias_method :path_to_video, :video_path # aliased to avoid conflicts with an video_path named route

     def audio_path(source)
       compute_public_path(source, 'audios')
     end
     alias_method :path_to_audio, :audio_path # aliased to avoid conflicts with an video_path named route

     # Returns an html video tag for the +sources+. If +sources+ is a string,
     # a single video tag will be returned. If +sources+ is an array, a video
     # tag with nested source tags for each source will be returned. The
     # +sources+ can be full paths or files that exists in your public videos
     # directory.
     #
     # ==== Options
     # You can add HTML attributes using the +options+. The +options+ supports
     # two additional keys for convenience and conformance:
     #
     # * <tt>:poster</tt> - Set an image (like a screenshot) to be shown
     #   before the video loads. The path is calculated like the +src+ of +image_tag+.
     # * <tt>:size</tt> - Supplied as "{Width}x{Height}", so "30x45" becomes
     #   width="30" and height="45". <tt>:size</tt> will be ignored if the
     #   value is not in the correct format.
     #
     # ==== Examples
     #  video_tag("trailer")  # =>
     #    <video src="/videos/trailer" />
     #  video_tag("trailer.ogg")  # =>
     #    <video src="/videos/trailer.ogg" />
     #  video_tag("trailer.ogg", :controls => true, :autobuffer => true)  # =>
     #    <video autobuffer="autobuffer" controls="controls" src="/videos/trailer.ogg" />
     #  video_tag("trailer.m4v", :size => "16x10", :poster => "screenshot.png")  # =>
     #    <video src="/videos/trailer.m4v" width="16" height="10" poster="/images/screenshot.png" />
     #  video_tag("/trailers/hd.avi", :size => "16x16")  # =>
     #    <video src="/trailers/hd.avi" width="16" height="16" />
     #  video_tag("/trailers/hd.avi", :height => '32', :width => '32') # =>
     #    <video height="32" src="/trailers/hd.avi" width="32" />
     #  video_tag(["trailer.ogg", "trailer.flv"]) # =>
     #    <video><source src="trailer.ogg" /><source src="trailer.ogg" /><source src="trailer.flv" /></video>
     #  video_tag(["trailer.ogg", "trailer.flv"] :size => "160x120") # =>
     #    <video height="120" width="160"><source src="trailer.ogg" /><source src="trailer.flv" /></video>
     def video_tag(sources, options = {})
       options.symbolize_keys!
  
       options[:poster] = path_to_image(options[:poster]) if options[:poster]
  
       if size = options.delete(:size)
         options[:width], options[:height] = size.split("x") if size =~ %r{^\d+x\d+$}
       end
  
       if sources.is_a?(Array)
         content_tag("video", options) do
           sources.map { |source| tag("source", :src => source) }.join
         end
       else
         options[:src] = path_to_video(sources)
         tag("video", options)
       end
     end
     
     def audio_tag(sources, options = {})
       options.symbolize_keys!
  
       options[:poster] = path_to_image(options[:poster]) if options[:poster]
  
       if size = options.delete(:size)
         options[:width], options[:height] = size.split("x") if size =~ %r{^\d+x\d+$}
       end
  
       if sources.is_a?(Array)
         content_tag("audio", options) do
           sources.map { |source| tag("source", :src => source) }.join
         end
       else
         options[:src] = path_to_audio(sources)
         tag("audio", options)
       end
     end
   end
 end
end 