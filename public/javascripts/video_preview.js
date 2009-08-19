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

var hook_up_preview = function(container){
  var container = $(container);
  var img = container.find('img');

  var checkForImgLoaded = function(img) {
    setTimeout(function(){
      if(!imgLoaded(img)) checkForImgLoaded(img);
      else loadSwf(img);
      return false;
    }, 10);
  }

  var loadSwf = function(img) {

    var flashvars = {
      previewURL: img.attr('src'),
      videoURL:   img.attr('rel'),
      totalTime:  5 * 60
    };

    container.empty().flash({
      src:       "/flash/CastPlayer.swf",
      width:     size.width,
      height:    size.height,
      flashvars: flashvars
    });
  }

  checkForImgLoaded(img);
};


$(document).ready(function () {
  $("body.episode.show .preview, li.episode.open p.preview").each(function(i, container){ 
    container = $(container);
    hook_up_preview(container);
  });
});