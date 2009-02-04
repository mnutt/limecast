$(document).ready(function() {
  // Edit Podcast link
  $('#edit_link').click(function() { $('.limecast_form').toggle(); return false; });
  $('.limecast_form .cancel').click(function(){ $(this).parents(".limecast_form").hide(); return false; });

  // Subscribe button
  $("#s_options_toggle").click(function(e){
    $("#subscribe_options_container").slideDown("fast");
		e.preventDefault();
  });

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

  $(".audio_player").hover(function(){
		$(this).find("a.popup").show();
  }, function(){
		$(this).find("a.popup").hide();
	});

  // Episodes/Reviews toggle links
  $(".supplemental h2.linkable a").click(function(e){
    $(".supplemental h2.linkable.current").removeClass('current');
    $(this).parent().addClass('current');
    $(this).addClass('current');

    $(".reviews.list").parents('.wrapper').toggle();
    $(".episodes.list").parents('.wrapper').toggle();
    return false;
  });
  
  $(".supplemental #r_view .linkable a").click(function(){
    $(".supplemental #r_view .linkable.current").removeClass('current');
    $(this).parent('span.linkable').addClass('current');

    if ($(this).attr('rel') == 'all') $(".reviews.list .review").show();
    else if ($(this).attr('rel') == 'positive') {
      $(".reviews.list .review.negative").hide();
      $(".reviews.list .review.positive").show();
    } else if ($(this).attr('rel') == 'negative') {
      $(".reviews.list .review.negative").show();
      $(".reviews.list .review.positive").hide();
    }
    
    return false;
  });

  
  // Dropdown JS initializer
  // <div.dropdown>
  //   <a.focuser> <--[the item that captures focus and closes/opens wrapper]
  //   <div.dropdown_wrap.rounded_corners> <--[a wrapper so the UL won't clash with rounded_corners]
  //     <--rounded corner wrapper divs-->
  //       <ul>
  //         <li>
  //           <a>
  $('.dropdown ul li a').click(function(){
    if($(this).hasClass('selected')) {
      event.stopPropagation();
    } else {
      $(this).parents(".dropdown").find("ul li").removeClass('selected');
      $(this).parent().addClass('selected');
      $(this).parents(".dropdown").toggleClass('open').find('a.focuser').html($(this).html());
    }
    return false;
  });

  $('.dropdown .focuser').click(function(){
    $(this).parents(".dropdown").toggleClass('open');
    return false;
  }).blur(function(event){
    // FIXME the blur action is conflicting with the "LI A" click events; also, doesn't seem to work in safari anymore?
    // $(this).parents(".dropdown").toggleClass('open');
    // return false;
  });
});

/**************************************************************
* Sign In
**************************************************************/
$(document).ready(function(){

  // Attach the global quick signup in the top-bar
  $('#header .signin a').click(function(){
    return $.quickSignIn.attach($('.quick_signin_container.from_top_bar'), {});
  });

});


/*
$.fn.extend({
  dropdown: function(opts){
    var me = $(this);
		opts.click = opts.click || function(){};

    var update_text = function(){
      me.find('> a').text( selected_text() );
    };

		var selected_text = function(){
      return me.find('ul li.selected a').text();
    };

		var selected_data = function(){
		  var data = me.find('ul li.selected span').text();

			if(data != "")
			  return data;
  		else
				return selected_text();
		};

    me.find('ul li a').click(function(){
      me.find('ul li').removeClass('selected');
      $(this).parent().addClass('selected');
      update_text();

			opts.click( selected_data() );
    });

    me.find('> a').click(function(){
      me.find("div").toggle();
    });

    update_text();

    return me;
  }
}); */

