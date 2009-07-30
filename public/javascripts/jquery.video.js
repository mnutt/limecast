// Jquery Video
// by: tzaharia
jQuery.fn.extend({
  video: function(value, options) {
    this.each(function(){
      var tag = $(this).attr('controls', false);

      var play1 = $('<button class="play1">▷</button>').
        css({top:'37.5%',left:'40%',width:'20%',height:'22.5%',position:'absolute',zIndex:99}).
        click(function(){
          tag[0].play(); play1.hide(); play2.hide(); pause.show();
        });
      var play2 = $('<button class="play2">▷</button>').
        css({position:'absolute',width:'7.5%',height:'7.5%',bottom:'5px',left:'2.5%'}).
        click(function(){
          tag[0].play(); play1.hide(); play2.hide(); pause.show();
        });
      var pause = $('<button class="pause">||</button>').
        css({position:'absolute',width:'7.5%',height:'7.5%',bottom:'5px',left:'2.5%',display:'none'}).
        click(function(){
          tag[0].pause(); play2.hide(); play2.show();
        });

      tag.wrap('<figure style="position: relative; z-index: 98; display: inline-block;" />').
        after(play1).after(play2).after(pause);

      //tag.css('visibility', 'hidden');

      // test
      // var videoSection = document.getElementById('video');
      // var videoElement = document.createElement('video');
      // var support = videoElement.canPlayType('video/x-new-fictional-format;codecs="kittens,bunnies"');
      // if (support != "probably" && "New Fictional Video Plug-in" in navigator.plugins) {

    });
  }
});

$(function() {
  $('video').video();
});