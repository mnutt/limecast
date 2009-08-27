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

    var current = (t.attr('flash_id') ? (soundManager.getSoundById(t.attr('flash_id')).position/1000) : t.attr('currentTime')) || 0;
    var total = (t.attr('flash_id') ? t.duration() : t.attr('duration')) || 0;
    if(total == 0) total = 1;
    t.parent().find('.time').html(current.secondsToTime() + " / " + total.secondsToTime());
    t.parent().find('.progress div').css('width', (current/total)*100+"%");
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
    if(t.attr('flash_id')) soundManager.play(t.attr('flash_id'));
    else t[0].play();

    if(!t.data("interval") || t.data("interval") == undefined) { // TODO add a fallback w/whilePlaying for SoundManager sounds
      t.data("interval", window.setInterval(function(){ t.updateMediaProgress(); }, 100));
    };
  },
  
  pause: function() {
    var t = $(this);
    if(t.attr('flash_id')) soundManager.pause(t.attr('flash_id'));
    else t[0].pause();

    window.clearInterval(t.data("interval")); // TODO add a fallback w/whilePlaying for SoundManager sounds
    t.data("interval", null);
  },
  
  paused: function() {
    var t = $(this);
    return (t.attr('flash_id') ? soundManager.getSoundById(t.attr('flash_id')).paused : t[0].paused);
  },

  setCurrentTime: function(pos) {
    var t = $(this);

    if (t.attr('flash_id')) {
      soundManager.getSoundById(t.attr('flash_id')).setPosition(pos * 1000);
    } else { 
      try { t.attr('currentTime', pos); } catch(e) { console.log("Error: "+e); }; // If it's not fully loaded
    };
  },
  
  updateTime: function(){ 
    var t = $(this);
    t.parent().find('.time').html((0).secondsToTime() + ' / ' + t.duration().secondsToTime());
  },
  
  setVolume: function(vol) {
    var t = $(this);
    if (t.attr('flash_id')) soundManager.getSoundById(t.attr('flash_id')).setVolume(vol*100);
    else t.attr('volume', vol);
  },
  
  duration: function() {
    var t = $(this);
    if(t.attr('flash_id')) {
      var s = soundManager.getSoundById(t.attr('flash_id'));
      return (s.duration == 0 ? s.durationEstimate : s.duration) / 1000;
    } else {
      return t.attr('duration');
    };
  },
  
  mute: function() {
    var t = $(this);
    if(t.attr('flash_id')) soundManager.getSoundById(t.attr('flash_id')).toggleMute();
    else t.attr('muted', !t.attr('muted'));
  },

  loadSoundManager: function() {
    $('<script src="/javascripts/soundmanager2.js" type="text/javascript"></script>').appendTo(document.body);
    soundManager.url = '/flash/soundmanager2.swf';
    soundManager.debugMode = false;
  },

  fallbackToFlashAudio: function() {
    $.fn.loadSoundManager();
    var audio_tags = $(this);
    
    soundManager.onload = function() {
      audio_tags.each(function() {
        var audio = $(this);
        audio.attr('flash_id', audio.attr('id')+'_flash').attr('is_flash'); // the ref for soundmanager
        soundManager.createSound({
          id: audio.attr('flash_id'), 
          url: audio.attr('src')
          // autoload: true,
          // whileloading: function(){ audio.updateTime(); },
        });
        audio.initMediaControls();
      });
    };
  },
  
  fallbackToFlashVideo: function() {
    var video_tags = $(this);

    video_tags.each(function(){
      var video = $(this);
      video.attr('is_flash',true); // just so we know it's flash
      var poster = video.attr('poster');
      var source = $(this).attr('src');
      var img = $('<img style="visibility: hidden; position: absolute; top: -5000px;" src="'+poster+'" />').appendTo(document.body);
      var i = 0;
      function addFlash() {
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
            appendTo(video.parent());
        }
      };
      addFlash();
      video.initMediaControls();
    });
  },
  
  initAudio: function() {
    var audio_tags = $(this);
    if(audio_tags.size() == 0) return false;

    // Check for audio tag and audio codec support
    var format = audio_tags.attr('src').split('.').pop();
    if(format == 'mp3' || format == 'mp4') format = 'mpeg';
    if (!audio_tags[0].canPlayType || (audio_tags[0].canPlayType('audio/'+format) != "maybe" && audio_tags[0].canPlayType('audio/'+format) != "probably"))
      audio_tags.fallbackToFlashAudio();
    else
      $.each(audio_tags, function(i, a){ $(a).show().initMediaControls() });
  },
  
  initVideo: function() {
    var video_tags = $(this);
    if(video_tags.size() == 0) return false;

    // Check for video tag and video codec support
    // if (!video_tags[0].canPlayType || (video_tags[0].canPlayType && video_tags[0].canPlayType('video/mp4') == "no" && video_tags[0].canPlayType('video/ogg') == "no"))
    // ***************************
    // NOTE: had problems with encoded FLV previews (frozen Safari & FF), so we're going to use 
    //       Flash Video for all, for now :( 
    if (true) 
     video_tags.fallbackToFlashVideo();
    else 
      $.each(video_tags, function(i, v){ $(v).show().initMediaControls() });
  },
  
  initMediaControls: function() {
    var tag = $(this).attr('controls', false).mousedown(function(){
      if(tag.paused()) { tag.play(); start.hide(); play.hide(); pause.show();}
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
    var progress = controls.find('.progress').
      attr('value', 0).
      click(function(e){
        var left = progress.pagePosition().left + 30;
        var ratio = ((e.pageX - left) / progress[0].clientWidth);
        var pos = ratio * tag.duration();
        tag.setCurrentTime(pos);
        tag.updateMediaProgress();
      });
    var time = controls.find('.time');
    
    if (!tag.attr('flash_id')) setTimeout(function(){ tag.updateTime }, 500); // update the time after loaded

    var mute = controls.find('.mute').mousedown(function(){ tag.mute(); mute.toggleClass('muted'); });
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
      tag.setVolume(vol);
      e.stopPropagation();
      return false;
    });

    tag.updateMediaProgress();
    if(!tag.attr('is_flash')) controls.show();
  }
});

$(function() {
  $('.video').initVideo();
  $('.audio').initAudio();
});