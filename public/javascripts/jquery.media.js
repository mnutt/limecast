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
    t[0].play();
    if(!t.data("interval") || t.data("interval") == undefined) {
      t.data("interval", window.setInterval(function(){ t.updateMediaProgress(); }, 100));
    };
  },
  
  pause: function(){
    t = $(this);
    t[0].pause();
    window.clearInterval(t.data("interval"));
    t.data("interval", null);
  },

  fallbackToFlashAudio: function() {
    this.each(function(){
      var audio = $(this);
      var source = $(this).find('source').attr('src');
      var width = (audio.attr('width') || 540);
      $('<script src="/flash/audio-player/audio-player.js" type="text/javascript"></script>').appendTo(document.body);
      AudioPlayer.setup("/flash/audio-player/player.swf", { width: width });
      AudioPlayer.embed(audio.attr('id'), {  
          soundFile: source,
          titles: audio.attr('rel'),
          autostart: "no"  
      });
    });
  },
  
  fallbackToFlashVideo: function() {
    this.each(function(){
      var video = $(this);
      var poster = video.attr('poster');
      var source = $(this).find('source').attr('src');
      var img = $('<img style="visibility: hidden;" src="'+poster+'" />').appendTo(document.body);
      var i = 0;
      var addFlash = function(){
        if(img.attr('width') == 0) {
          setTimeout(addFlash, 100);
        } else {
          var width = (video.attr('width') || img.attr('width'));
          var height = (width / img.attr('width')) * img.attr('height');
          var embed = $('<embed pluginspage="http://www.adobe.com/go/getflashplayer" type="application/x-shockwave-flash" />').
            attr('flashvars', 'previewURL='+poster+'&videoURL='+source+'&totalTime='+300).
            attr('width', width).
            attr('height', height).
            attr('src', '/flash/CastPlayer.swf').
            appendTo(video);
        }
      }();
    });
  },
  
  initAudio: function() {
    var audio = $(this);
    if(audio.size() == 0) return false;

    // Check for audio tag and audio codec support
    var format = audio.find('source')[0].src.split('.').pop();
    if (!audio[0].canPlayType || (audio[0].canPlayType('audio/'+format) != "maybe" && audio[0].canPlayType('audio/'+format) != "probably")) {
      this.fallbackToFlashAudio();
      return false;
    }
    
    this.initMediaControls();
  },
  
  initVideo: function() {
    var video = $(this);
    if(video.size() == 0) return false;

    // Check for video tag and video codec support
    if (!video[0].canPlayType || (video[0].canPlayType('video/mp4') == "no" && video[0].canPlayType('video/ogg') == "no")) {
      this.fallbackToFlashVideo();
      return false;
    }
    this.initMediaControls();
  },
  
  initMediaControls: function() {
    var tag = $(this).attr('controls', false).mousedown(function(){
      if(tag[0].paused) { tag.play(); start.hide(); play.hide(); pause.show();}
      else { tag.pause(); play.show(); pause.hide() };
    });
    var container = tag.parent().css('width', '540px');
    var controls = container.find('.controls');
    var start = controls.find('.start').mousedown(function(){
      tag.play(); start.hide(); play.hide(); pause.show();
    });
    var play = controls.find('.play').mousedown(function(){
      tag.play(); if(start) start.hide(); play.hide(); pause.show();
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
        tag.attr('currentTime', pos);
        tag.updateMediaProgress();
      });
    var time = controls.find('.time');
    setTimeout(function(){ time.html((0).secondsToTime() + ' / ' + (tag.attr('duration') || 0).secondsToTime()) }, 500);
    var mute = controls.find('.mute').mousedown(function(){
      tag.attr('muted', !tag.attr('muted'));
      mute.toggleClass('muted');
    });
    var volume = controls.find('.volume');
    var volume_buttons = volume.find('button').mousedown(function(e){
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
   controls.show();
  }
});

$(function() {
  $('video').initVideo();
  $('audio').initAudio();
});