// Jquery A/V Controls
// adds customizable controls via JQuery to a <video> tag
// by: tzaharia
Number.prototype.secondsToTime = function() { 
  var zero_padding = function(i){return((i<10)?("0"+i):i);};
  var sec = Math.floor(this);
  return (zero_padding(Math.round(sec/60)) + ":"+ zero_padding(sec%60));
};

jQuery.fn.extend({
  updateMediaProgress: function(){
    var t = $(this);
    var x = t.attr('currentTime');
    var y =  (t.attr('duration') || 0);
    t.parent().find('.time').html(x.secondsToTime() + " / " + y.secondsToTime());
    t.parent().find('progress div').css('width', (x/y)*100+"%");
  },

  // Get the offset position relative to page
  pagePosition: function(){
    var left = 0;
    var top = 0;
    var el = this[0];
    if (el.offsetParent) {
      while (el = el.offsetParent) {
        left += el.offsetLeft;
        top += el.offsetTop;
      };
    };
    return {left: left, top: top};
  },
  
  play: function() {
    var t = $(this);
    if(t.attr('tagName') == "VIDEO") {
      t[0].play();
      if(t.data("interval") == undefined) {
        t.data("interval", window.setInterval(function(){ t.updateMediaProgress(); }, 100));
      };
    }
  },
  
  pause: function(){
    t = $(this);
    if(t.attr('tagName') == "VIDEO") {
      t[0].pause();
      window.clearInterval(t.data("interval"));
      t.data("interval", null);
    }
  },
  
  initVideo: function(value, options) {
    this.each(function(){
      var tag = $(this).attr('controls', false).mousedown(function(){
        if(tag[0].paused) { tag.play(); start.hide(); play.hide(); pause.show();}
        else { tag.pause(); play.show(); pause.hide() };
      });
      var container = tag.parent();
      var controls = container.find('.controls');
      var start = controls.find('.start').mousedown(function(){
        tag.play(); start.hide(); play.hide(); pause.show();
      });
      var play = controls.find('.play').mousedown(function(){
        tag.play(); start.hide(); play.hide(); pause.show();
      });
      var pause = controls.find('.pause').mousedown(function(){
        tag.pause(); play.show(); pause.hide();
      });
      var progress = controls.find('progress').
        attr('max', tag.
        attr('duration')).
        attr('value', 0).
        click(function(e){
          var left = progress.pagePosition().left + 30;
          var ratio = ((e.pageX - left) / progress[0].clientWidth);
          var pos = ratio * tag[0].duration;
          tag[0].currentTime = pos;
          tag.updateMediaProgress();
        });
      var time = controls.find('.time').html((0).secondsToTime() + ' / ' + (tag.attr('duration') || 0).secondsToTime());
      var mute = controls.find('.mute').mousedown(function(){
        tag.attr('muted', !tag.attr('muted'));
        mute.toggleClass('muted');
      });
      var volume = controls.find('.volume');
      var volume_buttons = volume.find('button').mousedown(function(){
        volume_buttons.removeClass('selected');
        $(this).addClass('selected');
        switch($(this).val()) {
          case 'very-quiet': var vol = 0.1; break;
          case 'quiet': var vol = 0.3; break;
          case 'medium': var vol = 0.5; break;
          case 'loud': var vol = 0.8; break;
          case 'very-loud': var vol = 1.0; break;
        }
        if (tag.attr('muted')) mute.mousedown();
        tag.attr('volume', vol);
        e.stopPropagation();
        return false;
      });

     tag.updateMediaProgress();
    });
  }
});

$(function() {
  $('video').initVideo();
});