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

$.ajaxSetup({
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})


// Method hooks up all of the input text boxes that should have default labels
function defaultText() {
  $("#feed_url, #accounts_forgot_password #email, #search_podcast_q, " + 
    ".limecast_form .new_podcast_feed_url, #q, #user_tagging_tag_string").inputDefaultText();
}

// Handles truncated "more" and "less" links
function truncatedText() {
  $("a.truncated").click(function(){
    var text = $(this).text();
    var oppositeText = text == "less" ? "more" : "less";

    $(this).text(oppositeText);
    $(this).parent().find(".truncated." + oppositeText).hide();
    $(this).parent().find(".truncated." + text).show();

    return false;
  }); 
}

function podcastEpisodeSorting() {
  var title = { "bSortable": false };
  var description = { "bVisible":    false, "bSortable": false };
  var runtime = { "bSortable": false };
  var date_released = null;
  
  $('#podcast_episodes').dataTable({
    "aaSorting": [[ 3, "desc" ]],
    "aoColumns": [ title, description, runtime, date_released ],
    "bStateSave": true,
    "bProcessing": true
  });
}

function favoriteLink() {
  $('a.favorite_link').click(function() {
    if(LOGGED_IN) {
      var favorite_link = $(this);
      var favorite_url = favorite_link.attr('href');
  
      $.post(favorite_url, {}, function(resp) { window.location.reload(); }, 'json');
    }
    return false;
  });
}

function setupNotLoggedInCluetips() {
  if(!LOGGED_IN) {
    var default_options = { local: true, arrows: true, width: 350, showTitle: false };
    $('a.tips').cluetip(default_options);

    default_options = $.extend({activation: 'click', sticky: true, onShow: function(){$.quickSignIn.setup()}}, default_options);

    var options = $.extend({positionBy: 'auto', leftOffset: -50}, default_options);
    $('#podcast_tag_form .submit').cluetip(options);
    
    default_options = $.extend({positionBy: 'bottomTop', topOffset: 25}, default_options);
    $('a.login').cluetip(default_options); 

    default_options = $.extend({onShow: function(){ $.quickSignIn.showSignUp(); $.quickSignIn.setup(); }}, default_options);
    $('a.signup').cluetip(default_options);
  }
}

$(document).ready(function() {
  defaultText();
  truncatedText();
  podcastEpisodeSorting();
  favoriteLink();
  setupNotLoggedInCluetips();

  
  // Add Podcast link
  $('a.cluetip_add_link').cluetip({
    local: true, 
    hideLocal: true, 
    arrows: true, 
    width: 350,  
    sticky: true,
    showTitle: false, 
    activation: 'click', 
    positionBy: 'auto',
    topOffset: 25,
    onShow: function(){ $.quickSignIn.setup(); }
  })
  
  
  // Makes clicking labels check their associated checkbox/radio button
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

  var hook_up_preview = function(){
    var preview = $(".preview .container img");
    var url = window.location.href;

    if(!imgLoaded(preview)) { return };

    function scale(height,width) {
      var scaleToWidth = 460;
      var h = (scaleToWidth / width) * height;
      return {height: h, width: Math.round(scaleToWidth)};
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
  };

  // Video Preview
  // XXX: Hack. We call this method twice because if the image is already cached,
  // load never gets executed. I added imgLoaded(img) so that the code is only executed
  // once, but we could probably make a much less hacky script if we add a random number
  // as a query string to the img request so that the img is never cached.
  $(".preview .container img").load(function(){
    hook_up_preview();
  });
  hook_up_preview();
  
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
  
  // Tabs
  $tabs = $('.tabify').tabs({
    navClass: 'tabs',
    containerClass: 'tabs-cont'
  });

  // Hover/Focus Behaviors
  $('input:not([type=hidden]), textarea, button').hoverAndFocusBehavior();

});





