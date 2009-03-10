if(typeof $=='undefined') throw("application.js requires the $ JavaScript framework.");

$(document).ready(function() {

  // Default text
  $('#feed_url').inputDefaultText();
  $('#q').inputDefaultText();
  $('#accounts_forgot_password #email').inputDefaultText();
  $('.limecast_form .new_podcast_feed_url').inputDefaultText();
  $('#search_podcast_q').inputDefaultText();

  // Handles truncated "more" and "less" links
  $("a.truncated").click(function(){
    var text = $(this).text();
    var oppositeText = text == "less" ? "more" : "less";

    $(this)
      .text(oppositeText)
      .parent()
        .find(".truncated." + oppositeText)
          .hide()
        .end()
        .find(".truncated." + text)
          .show()
        .end();

    return false;
  });


  if($('.podcast.show').size() && !$('.podcast.new.show').size()) {
    $('#podcast_episodes').dataTable({
      "aaSorting": [[ 3, "desc" ]],
      "aoColumns": [ 
           /* Title */   { "bSortable": false },
           /* Description */  { "bVisible":    false, "bSortable": false },
           /* Runtime */ { "bSortable": false },
           /* Date released */  null
           ],
        "bStateSave": true,
        "bProcessing": true
      });
      $('a.tips').cluetip({local: true, hideLocal: true, arrows: true, width: 350,  showTitle: false});
  }

 	$('a.login').cluetip({
 	  local: true, 
 	  hideLocal: true, 
 	  arrows: true, 
 	  width: 350,  
 	  sticky: true,
 	  showTitle: false, 
 	  activation: 'click', 
 	  positionBy: 'bottomTop', 
 	  topOffset: 25,
 	  onShow: function(){
      $("#cluetip-close").click($.quickSignIn.reset);
      $.quickSignIn.setup();
 	  }
 	});


  // Favorite link
  $('a.favorite_link').click(function() {
    var favorite_link = $(this);
    var favorite_url = favorite_link.attr('href');
  
    $.post(favorite_url, {}, function(resp) {
      if(resp.logged_in) {
        window.location = window.location;
      } else {
        // replace with cluetip
        $.quickSignIn.attach(
          favorite_link.parents('.description').find('.quick_signin_container.after_favoriting'), 
          {message:'Sign up or sign in to save your favorite.'}
        );
      }
    }, 'json');
    return false;
  });
  // Makes clicking labels check their associated checkbox/radio button
});


if(typeof $=='undefined') throw("application.js requires the $ JavaScript framework.");

//*************************************************************
// Hover/Focus Behaviors
//**************************************************************/
$.fn.extend({
  hoverAndFocusBehavior: function() {
    $(this).mouseover(function() { $(this).addClass('hover'); })
           .mousedown(function() { $(this).addClass('active'); })
           .mouseup(function() { $(this).removeClass('active'); })
           .mouseout(function() { $(this).removeClass('hover active'); })
           .focus(function() { $(this).addClass('focus').removeClass('active hover'); })
           .blur(function() { $(this).removeClass('focus hover active'); });
  }
});
$(document).ready(function() {
  $('input:not([type=hidden]), textarea, button').hoverAndFocusBehavior();
});

//*************************************************************
// Toggle
//************************************************************/
$(document).ready(function(){
  $('li.expandable').map(function(){
    var expandable_li = $(this);

    expandable_li.find('span.expand').click(function(){
      if(expandable_li.hasClass('expanded')) {
        expandable_li.removeClass('expanded');
        expandable_li.find('span.expand').text('Collapse');
      } else {
        expandable_li.addClass('expanded');
        expandable_li.find('span.expand').text('Expand');
      }
    });
  });
});


// Makes clicking labels check their associated checkbox/radio button
$(document).ready(function(){
  $('label').map(function(){
    var field = $('#' + $(this).attr('for'));
    if(field.is('input[type=radio]') || field.is('input[type=checkbox]')) {
      $(this).click(function() {
        field.attr('checked', true);
      });
    }
  });

  // Video Preview
  $(".preview .container img").load(function(){
    var preview = $(this);

    var url = window.location.href;

    function scale(height,width) {
      var scaleToWidth = 460;
      var h = (scaleToWidth / width) * height;
      return {height: h, width: scaleToWidth};
    }
    var scaledSize = scale(preview.height(), preview.width());

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
  });
  
  $("#subscribe_options li a").click(function(){ return false; });

  $("#s_options_toggle").click(function(e){
    $("#subscribe_options_container").slideDown("fast");

    // similar to jquery.dropdown.js
    if($("#overlay").size() == 0) $('body').append("<div id=\"overlay\"></div>");
    $("#overlay").click(function(){
      $("#subscribe_options_container").slideUp("fast");
      $(this).remove();
    });

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

  // Tabs
  $tabs = $('.tabify').tabs({
    navClass: 'tabs',
    containerClass: 'tabs-cont'
  });

  // Hover/Focus Behaviors
  $('input:not([type=hidden]), textarea, button').hoverAndFocusBehavior();

});





