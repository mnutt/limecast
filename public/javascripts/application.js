if(typeof $=='undefined') throw("application.js requires the $ JavaScript framework.");

/**************************************************************
* Hover/Focus Behaviors
**************************************************************/
$(document).ready(function() {
  var elements = $('input, textarea, button');
  var options = {
    prefix: '_',
    classNames: {
      hover: 'hover',
      focus: 'focus'
    }
  }
  elements.each(function() {
    var me = $(this);
    var type = me.attr('type');
    if (type != 'hidden') {
      if (type == 'image') {
        var filename = me.attr('src');
        var dot = filename.lastIndexOf('.');
        var filename_hover = filename.substr(0, dot) + options.prefix + options.classNames.hover + filename.substr(dot);
        var filename_focus = filename.substr(0, dot) + options.prefix + options.classNames.focus + filename.substr(dot);
      }
      me.mouseover(function(e) {
        if (type == 'image') me.attr({src: filename_hover});
        me.addClass(options.classNames.hover);
      })
      .mouseout(function(e) {
        if (type == 'image') me.attr({src: filename});
        me.removeClass(options.classNames.hover);
      })
      .focus(function(e) {
        if (type == 'image') me.attr({src: filename_focus});
        me.removeClass(options.classNames.hover)
          .addClass(options.classNames.focus);
      })
      .blur(function(e) {
        if (type == 'image') me.attr({src: filename});
        me.removeClass(options.classNames.hover)
          .removeClass(options.classNames.focus);
      });
    }
  });
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
  me.find('.response_container .inline_signup_button').click(function() {
    me.find('input.signup_button').click();
    me.find('input.email').val(me.find('input.login').val());
    me.find('input.login').val("");
    me.find('div.response_container').html("<p>Please choose your new user name</p>");
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
        query: searchBox,
        format: function(s) { return '<b>' + s + '</b>'; }
      });
    });
  }
});

/**************************************************************
* Reflection
**************************************************************/

$(document).ready(function(){
  $('img.reflect').reflect({height: 0.3, opacity: 0.3}); 
});
