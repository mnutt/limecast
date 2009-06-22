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

var hook_up_preview = function(preview){
  var func = function(i, preview) {
    var preview = (typeof i == 'number') ? $(preview) : $(i);
    var url = window.location.href;

    function scale(height,width) {
      var scaleToWidth = 460;
      var h = (scaleToWidth / width) * height;
      return {height: h + 2, width: Math.round(scaleToWidth)};
    }
    var size = {height: preview.height(), width: preview.width()};
    var scaledSize = preview.hasClass('scale') ? scale(size.height, size.width) : size;

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
  }
  
  if(preview) {
    func(preview);
    window.clearInterval(preview.attr('interval'));
  } else {
    $(".preview .container img").each(func);
  };
};


$(function(){  
  $(".preview .container img").each(function(i, img){ 
    img = $(img);
    img.attr('interval', setInterval(function(){
      if(imgLoaded(img)) hook_up_preview(img);
    }, 100));
  });

});