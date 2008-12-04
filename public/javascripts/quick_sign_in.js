$.quickSignIn = {
  isHidden: function()  { return ($("#quick_signin").css('display') == 'none'); },
  isVisible: function() { return ($("#quick_signin").css('display') != 'none'); },

  setup: function() {
    var me = $("#quick_signin");

    // Makes the form use AJAX
    me.submit(function(event){
      return false;
      //callback = (event.originalEvent.explicitOriginalTarget.id == 'signup') ? $.quickSignIn.signupSubmitCallback : $.quickSignIn.signinSubmitCallback;
      $.post(me.attr('action'), me.serialize(), $.quickSignIn.signinSubmitCallback, 'json');

      return false;
    });

    // Show the full signup form on clicking the 'Sign Up' button
    me.find('.signup_button').click(function(event){
      $.post(me.attr('action'), me.serialize(), $.quickSignIn.signupSubmitCallback, 'json'); // if (me.find('input.signin_button:visible').length > 0 && event.detail > 0 ) {}  // event.detail = # of mouse clicks
    });

    me.find('.signin_button').click(function(event){
      $.post(me.attr('action'), me.serialize(), $.quickSignIn.signinSubmitCallback, 'json');
    });
    
    // Handles clicking the X button to close the quick sign in box
    me.find('a.close').click(this.reset);

    // Keypress to handle pressing escape to close box.
    me.find('input').keydown(function(e){ if(e.keyCode == 27) $.quickSignIn.reset(); }); 

    return me;
  },
  
  signinSubmitCallback: function(resp){
    if(resp.success) { window.location.reload(); }
    else {
      resp_container = me.find('.response_container');

      if(resp.html == resp_container.html()) resp_container.hide().fadeIn();
      else resp_container.html(resp.html);
    
      // Attach event to 'Are you trying to Sign Up?' link
      if(me.find('.inline_signup_button').length) me.find('.inline_signup_button').click($.quickSignIn.showSignUp);
    
      // implement callbacks here if we ever need to.
     
      return false;
    }
  },

  signupSubmitCallback: function(resp){
    if(resp.success) { window.location.reload(); }
    else {
      $.quickSignIn.showSignUp();
    }

    return false;
  },

  reset: function() {
    me = $("#quick_signin");
    me.hide();
    me.find('.message').html('');
    me.find('.sign_up').hide();
    me.attr('action', '/session');
    me.find('input.signin_button').show();
    me[0].reset(); // the actual DOM function for resetting a form
    me.find('div.response_container').html('<a href="/forgot">I forgot my password</a>');
  },
  
  attach: function(element, options) {
    var me = $("#quick_signin");
    var element = $(element);

    if(me.parent()[0] == element[0]) { // if it's already attached
      me.toggle();
      if($.quickSignIn.isHidden()) $.quickSignIn.reset();
      else me.find('input.login')[0].focus();
    } else {
      $.quickSignIn.reset();
      element.append(me);
      me.show().find(".message").html(options.message);
      me.find('input.login')[0].focus();
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
    me.find('div.response_container').html("<p>Choose your new user name.</p>");
    return false;
  }
}

// Initialize the quick sign in
$(document).ready(function(){
  $.quickSignIn.setup();
});
