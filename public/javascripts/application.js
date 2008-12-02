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
  var signin_container = $('.quick_signin.top_bar');

  function reset_container() {
    signin_container.hide();
    signin_container.find('.sign_up').hide();
    signin_container.find('form').attr('action', '/session');
    signin_container.find('input.signin_button').show();
    signin_container.find('form')[0].reset();
    signin_container.find('div.response_container').html('<a href="/forgot_password">I forgot my password</a>');
  }

  signin_container.quickSignIn({
    success: function(resp){
      reset_container();
      $('#account_bar .signup').unbind('click');
    },
    error: function(resp) {
      me = signin_container;
      
      if(me.find('.response_container .inline_signup_button')) {
        me.find('.response_container .inline_signup_button').click(function(ev) {
          me.find('input.signup_button').click(); // show the signup form
          if(me.find('input.login').val().match(/[^ ]+@[^ ]+/)) {
            me.find('input.email').val(me.find('input.login').val());
            me.find('input.login').val("");
          }
          me.find('div.response_container').html("<p>Please choose your new user name</p>");
          //ev.preventDefault();
      });
      }
    }
  });

  // Keypress to handle pressing escape to close box.
  signin_container.find('input').keydown(function(e){
    if(e.keyCode == 27) { reset_container(); }
  });
  $('#account_bar .signup').click(function(){
    if(signin_container.css('display') == 'none') {
      signin_container.show();
      signin_container.find('input.login').focus();
    } else {
      reset_container();
    }

    return false;
  });
  signin_container.find('a.close').click(function(){
    reset_container();
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
        query: searchBox
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