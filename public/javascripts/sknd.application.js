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

  // Episodes/Reviews toggle links
  $(".supplemental h2.linkable a").click(function(){
    $(".supplemental h2.linkable.current").removeClass('current');
    $(this).addClass('current');

    $("#s_episodes_wrap").toggle();
    $("#s_reviews_wrap").toggle();
  });
  
  $(".supplemental #r_view .linkable a").click(function(){
    $(".supplemental #r_view .linkable.current").removeClass('current');
    $(this).parent('span.linkable').addClass('current');

    if ($(this).attr('rel') == 'all') $("#s_reviews .review").show();
    else if ($(this).attr('rel') == 'positive') {
      $("#s_reviews .review.negative").hide();
      $("#s_reviews .review.positive").show();
    } else if ($(this).attr('rel') == 'negative') {
      $("#s_reviews .review.negative").show();
      $("#s_reviews .review.positive").hide();
    }
    
    return false;
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

