// ---------------------------------
// START STUFF MOVED OVER FROM SKND
// ---------------------------------
$(document).ready(function() {
  // Edit Podcast link
  $('#edit_link').click(function() { 
    $('.limecast_form').toggle(); 
    $(this).hide(); 
    return false; 
  })
  $('#edit_actions').show(); // we hide the edit link until ready in case the user clicks it

  $('.limecast_form .cancel').click(function(){ 
    $('#edit_link').show(); 
    $(this).parents(".limecast_form").hide(); 
    return false;
  });

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
    $('#podcast_episodes').dataTable( {
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
});


// ---------------------------------
// END STUFF MOVED OVER FROM SKND
// ---------------------------------

$(document).ready(function(){
  $('a.favorite_link').click(function() {
    var favorite_link = $(this);
    var favorite_url = favorite_link.attr('href');
  
    $.post(favorite_url, {}, function(resp) {
      if(resp.logged_in) {
        window.location = window.location;
      } else {
        $.quickSignIn.attach(
          favorite_link.parents('.description').find('.quick_signin_container.after_favoriting'), 
          {message:'Sign up or sign in to save your favorite.'}
        );
      }
    }, 'json');
    return false;
  });
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
// Sign In
//************************************************************/
$(document).ready(function(){
  // Attach the global quick signup in the top-bar
  $('#utility_nav .signin a').click(function(){
    return $.quickSignIn.attach($('.quick_signin_container.from_top_bar'), {toggle:false});
  });

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

  $('form.super_button').superButton();
});

// Hook up all of the search term highlighting
$(document).ready(function(){
  var searchLabel = $('label[for=q]').text();
  var searchBox   = $('input#q').val();
  if($(document).searchTermContext && searchLabel != searchBox) {
    $('#primary li .searched').map(function(){
      $(this).searchTermContext({
        query: searchBox,
        wordsOfContext: 5,
        format: function(s) { return '<span class="search_term">' + s + '</span>'; }
      });
    });
  }
});

//*************************************************************
// Video Preview
//************************************************************/
$(document).ready(function() {
  var preview = $(".preview .container img");
  var url = window.location.href
  var hasPlayInUrl = url.lastIndexOf("play") > url.lastIndexOf("?");

  var flashvars = {
    previewURL: preview.attr('src'),
    videoURL: preview.attr('rel'),
    playOnOpen: hasPlayInUrl
  };

  preview.parent('div').empty().flash({
    src:       "/flash/CastPlayer.swf",
    width:     preview.attr('width'),
    height:    preview.attr('height'),
    flashvars: flashvars
  });
});

$(document).ready(function() {
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


  $('.dropdown .focuser').click(function(){
    $(this).parents(".dropdown").toggleClass('open');
    return false;
  }).blur(function(event){
    // FIXME the blur action is conflicting with the "LI A" click events; also, doesn't seem to work in safari anymore?
    // $(this).parents(".dropdown").toggleClass('open');
    // return false;
  });
});


$(function() {
  $tabs = $('.tabify').tabs({
    navClass: 'tabs',
    containerClass: 'tabs-cont'
  });


});
