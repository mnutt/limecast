$(document).ready(function(){  
  // From http://www.sajithmr.com/javascript-check-an-image-is-loaded-or-not/
  var imgLoaded = function(img){
    if(!img.attr('complete')) {
      return false;
    }
    if(typeof img.attr('naturalWidth') != 'undefined' && img.attr('naturalWidth') == 0) {
      return false;
    }
    return true;
  }
  
  var hook_up_preview = function(){
    var preview = $(".preview .container img");
    var url = window.location.href;
  
    if(!imgLoaded(preview)) { return };
  
    function scale(height,width) {
      var scaleToWidth = 460;
      var h = (scaleToWidth / width) * height;
      return {height: h, width: Math.round(scaleToWidth)};
    }
    var scaledSize = scale(preview.height(), preview.width());
  
    var flashvars = {
      previewURL: preview.attr('src'),
      videoURL:   preview.attr('rel'),
      totalTime:  5 * 60
    };
  
    preview.parent('div').empty().flash({
      src:       "/flash/CastPlayer.swf",
      width:     scaledSize.width,
      height:    scaledSize.height,
      flashvars: flashvars
    });
  };
  
  // Video Preview
  // XXX: Hack. We call this method twice because if the image is already cached,
  // load never gets executed. I added imgLoaded(img) so that the code is only executed
  // once, but we could probably make a much less hacky script if we add a random number
  // as a query string to the img request so that the img is never cached.
  $(".preview .container img").load(function(){
    hook_up_preview();
  });
  hook_up_preview();
});