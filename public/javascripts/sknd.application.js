$(document).ready(function() {
  $(".audio_player .url").map(function(){
    var flashvars = {
      soundFile: $(this).attr('href')
    };

    var movie = $("<span />").flash({
      src:       "/flash/player.swf",
      width:     290,
      height:    24,
      flashvars: flashvars
    });

    $(this).parent().append(movie);

    return false;
  });

  // Podcasts#show / Reviews#list
  $("body.podcast.show h2.linkable").click(function(){
    $("#s_episodes").toggle();
  });
});

$.fn.extend({
  dropdown: function(){
    var me = $(this);

    var update_text = function(){
      me.find('> a').text(
        me.find('ul li.selected a').text()
      )
    }

    me.find('ul li a').click(function(){
      me.find('ul li').removeClass('selected');
      $(this).parent().addClass('selected');
      update_text();
    });

    me.find('> a').click(function(){
      $(this).parent().find("div").toggle();
    });

    update_text();

    return me;
  }
});

$(document).ready(function(){
  $('.dropdown').dropdown();
});

