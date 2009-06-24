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
  var screenshot = container.attr('poster');
  container.html('<img style="visibility: hidden;" alt="' + screenshot + '" src="' + screenshot + '" />');
  var img = container.find('img');

  var checkForImgLoaded = function(img) {
    setTimeout(function(){
      if(!imgLoaded(img)) checkForImgLoaded(img);
      else loadSwf(img);
      return false;
    }, 10);
  }

  var loadSwf = function(img) {
    if(container.hasClass('scale')) {
      var scaleToWidth = 460;
      var h = (scaleToWidth / img.attr('width')) * img.attr('height');
      var size = {height: h + 2, width: Math.round(scaleToWidth)};
    } else {
      var size = {height: img.attr('height'), width: img.attr('width')};
    }

    var flashvars = {
      previewURL: container.attr('poster'),
      videoURL:   container.attr('rel'),
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
  $(".expanded .preview .container").each(function(i, container){ 
    container = $(container);
    hook_up_preview(container);
  });
});