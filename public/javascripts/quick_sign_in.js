$.quickSignIn = {
  isHidden: function()  { return ($("#quick_signin").css('display') == 'none'); },
  isVisible: function() { return ($("#quick_signin").css('display') != 'none'); },

  setup: function() {
    var me = $("#quick_signin");

    // Makes the form use AJAX
    me.submit(function(){
      $.post(me.attr('action'), me.serialize(), // $.post(url, data, callback, type);
        function(resp){
          console.log(resp);
          if(resp.success) { window.location.reload(); }
          else {
            response_container = me.find('.response_container');
            if(resp.html == response_container.html()) {
              response_container.hide();
              response_container.html(resp.html);
              response_container.fadeIn();
            } else response_container.html(resp.html);
          
            // Attach event to 'Are you trying to Sign Up?' link
            if(me.find('.inline_signup_button').length) me.find('.inline_signup_button').click($.quickSignIn.showSignUp);
          
            // if(!opts.error) { opts.error(resp); } // TODO implement
          }
        }, 'json');

      return false;
    });

    // Show the full signup form on clicking the 'Sign Up' button
    me.find('.signup_button').click(function(event){
      if (me.find('input.signin_button:visible').length > 0 && event.detail > 0 ) { // event.detail = # of mouse clicks
         $.quickSignIn.showSignUp();
        return false;
      }
    });

    // Handles clicking the X button to close the quick sign in box
    me.find('a.close').click(this.reset);

    // Keypress to handle pressing escape to close box.
    me.find('input').keydown(function(e){ if(e.keyCode == 27) $.quickSignIn.reset(); }); 

    return me;
  },

  reset: function() {
    me = $("#quick_signin");
    me.hide();
    me.find('.sign_up').hide();
    me.attr('action', '/session');
    me.find('input.signin_button').show();
    me[0].reset();
    me.find('div.response_container').html('<a href="/forgot_password">I forgot my password</a>');
  },
  
  attach: function(element, options) {
    var me = $("#quick_signin");
    var element = $(element);

    if(me.parent()[0] == element[0]) { // if it's already attached
      me.toggle();
      if($.quickSignIn.isHidden()) $.quickSignIn.reset();
    } else {
      $.quickSignIn.reset();
      element.append(me);
      me.find(".message").html(options.message);
      me.show();
    }
    
    return false;
  },
  
  showSignUp: function() {
    me = $("#quick_signin");

    me.find('.sign_up').show();
    me.find('input.login').focus();
    me.find('input.signin_button').hide();
    me.attr('action', '/users'); // Set the forms action to /users to call UsersController#create

    if(me.find('input.login').val().match(/[^ ]+@[^ ]+/)) {
      me.find('input.email').val(me.find('input.login').val());
      me.find('input.login').val("");
    }
    me.find('div.response_container').html("<p>Please choose your new user name.</p>");
  }
}

// Initialize the quick sign in
$(document).ready(function(){
  $.quickSignIn.setup();
});
