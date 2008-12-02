if(typeof $=='undefined') throw("application.js requires the $ JavaScript framework.");

/**************************************************************
* Hover/Focus Behaviors
**************************************************************/
$.fn.extend({
  hoverAndFocusBehavior: function() {
    var me = $(this);
    me.mouseover(function() { me.addClass('hover');    });
	  me.mouseout(function()  { me.removeClass('hover'); });
		me.focus(function() { me.addClass('focus').removeClass('hover');    });
		me.blur(function()  { me.removeClass('focus').removeClass('hover'); });
  }
});
$(document).ready(function() {
  $('input:not([type=hidden]), textarea, button').hoverAndFocusBehavior();
});

/**************************************************************
* Sign In
**************************************************************/
$(document).ready(function(){
  var me = $('.quick_signin.top_bar');

  function reset_container() {
    me.hide();
    me.find('.sign_up').hide();
    me.find('form').attr('action', '/session');
    me.find('input.signin_button').show();
    me.find('form')[0].reset();
    me.find('div.response_container').html('<a href="/forgot_password">I forgot my password</a>');
  }

  // Keypress to handle pressing escape to close box.
  me.find('input').keydown(function(e){
    if(e.keyCode == 27) { reset_container(); }
  });

	// Handles clicking the X button to close the quick sign in box
  me.find('a.close').click(reset_container);

  me.quickSignIn({
    error: function(resp) {
      me.find('.response_container .inline_signup_button').click(function() {
        if (me.find('input.signin_button:visible').length) {
          me.showQuickSignUpForm();
        }
      });
    }
  });

  $('#account_bar .signup').click(function(){
    if(me.css('display') == 'none') {
      me.show();
      me.find('input.login').focus();
    } else {
      reset_container();
    }

    return false;
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
  $('form.super_button.subscribe').updateDeliveryForSubscribe();
});

// Hook up all of the search term highlighting
$(document).ready(function(){
  var searchLabel = $('label[for=q]').text();
  var searchBox   = $('input#q').val();
  if($(document).searchTermContext && searchLabel != searchBox) {
    $('#primary li .searched').map(function(){
      $(this).searchTermContext({
        query: searchBox,
        format: function(s) { return '<b>' + s + '</b>'; }
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