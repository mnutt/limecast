if(typeof $=='undefined') throw("application.js requires the $ JavaScript framework.");

/**************************************************************
* Hover/Focus Behaviors
**************************************************************/
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

/**************************************************************
* Sign In
**************************************************************/
$(document).ready(function(){

  // Attach the global quick signup in the top-bar
  $('#account_bar .signup a').click(function(){
    return $.quickSignIn.attach($('.quick_signin_container.from_top_bar'), {});
  });

});


/**************************************************************
* Toggle
**************************************************************/
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

/**************************************************************
* Reflection
**************************************************************/

// No ready() function because: http://groups.google.com/group/jquery-en/browse_thread/thread/0f8380107f9acdc7/29edd211094770e5
$(window).bind("load", function() {
  $('img.reflect').reflect({height: 0.3, opacity: 0.3});
});

/**************************************************************
* Video Preview
**************************************************************/
$(document).ready(function() {
  $(".preview a").click(function() {
    var flashvars = {
      videoURL: $(this).attr('rel'),
      playOnOpen: true
    };

    $(this).parent('div').empty().flash({
      src:       "/flash/LimePlayer.swf",
      width:     425,
      height:    355,
      flashvars: flashvars
    });

    return false;
  });
});

