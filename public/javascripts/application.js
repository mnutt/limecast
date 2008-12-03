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
  // Attach the global quick signup in the top-bar
  $('#account_bar .signup a').click(function(){ 
    return $.quickSignIn.attach($('.quick_signin_container.from_top_bar'), {});
  });

  // Attach the favorite quick signup
  if($(document).find('.quick_signin_container.after_favoriting').length) {
    $('a.favorite_link').unbind('click').click(function(){
      return $.quickSignIn.attach($('.quick_signin_container.after_favoriting'), 
              {message:'Sign up or sign in to save your favorite.'});
    });
  }
  
  
  // $('a.favorite_link').mustBeLoggedInBeforeSubmit({
  //   quick_signin: '.quick_signin.after_favoriting',
  //   success: function(resp) {
  //     $('a.favorite_link').replaceWith('<span><img src="/images/icons/favorite.png" class="inline_icon" />My Favorite</span>');
  //   }
  // });
  // 
  // $('.quick_signin.inline').quickSignIn({
  //   success: function(){ window.location.reload(); }
  // });
  
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