$.quickSignIn = {
  isHidden: function()  { return ($("#quick_signin").css('display') == 'none'); },
  isVisible: function() { return ($("#quick_signin").css('display') != 'none'); },

  setup: function() {
    var me = $("#quick_signin");

    // Makes the form use AJAX
    me.submit(function(event){
      return false; // this will all be handled through specific Form Element events
    });

    // Show the full signup form on clicking the 'Sign Up' button
    me.find('.signup_button').click(function(event){
      if(me.find('input.login').val().match(/^\s*$/)) { // if blank, don't bother w/AJAX call
        $.quickSignIn.showSignUp();
      } else {
        $.post(me.attr('action'), me.serialize(), $.quickSignIn.signupSubmitCallback, 'json'); // if (me.find('input.signin_button:visible').length > 0 && event.detail > 0 ) {}  // event.detail = # of mouse clicks
      }

      return false;
    });

    me.find('.signin_button').click(function(event){
      $.post(me.attr('action'), me.serialize(), $.quickSignIn.signinSubmitCallback, 'json');
      return false;
    });
    
    // Handles clicking the X button to close the quick sign in box
    me.find('a.close').click(this.reset);

    // Keypress to handle pressing escape to close box.
    me.find('input').keydown(function(e){ if(e.keyCode == 27) $.quickSignIn.reset(); }); 

    return me;
  },
  
  signinSubmitCallback: function(resp){
    me = $("#quick_signin");

    if(resp.success && me.attr('reloadPage') == 'false') { // success, no reload
      if(resp.profileLink) { $('#account_bar li.signup').removeClass('signup').addClass('user').html(resp.profileLink); }
      $.quickSignIn.updateResponse(resp.html);
    } else if(resp.success && me.attr('reloadPage') != 'false') { // success reload
      window.location.reload(); 
    } else { // no success
      $.quickSignIn.updateResponse(resp.html);

      // attach event to 'Are you trying to Sign Up?' link
      me.find('.inline_signup_button').click($.quickSignIn.showSignUp);
    }
    return false;
  },

  signupSubmitCallback: function(resp){
    me = $("#quick_signin");

    if(resp.success && me.attr('reloadPage') == 'false') { // success, no reload
      if(resp.profileLink) { $('.signup').removeClass('signup').addClass('user').html(resp.profileLink); }
      $.quickSignIn.updateResponse(resp.html);
    } else if(resp.success && me.attr('reloadPage') != 'false') { // success reload
      window.location.reload(); 
    } else { // no success
      $.quickSignIn.showSignUp();

      $.quickSignIn.updateResponse(resp.html);

      // attach event to 'Are you trying to Sign Up?' link
      me.find('.inline_signup_button').click($.quickSignIn.showSignUp);
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

  // Attaches the Quick Signin form to a container
  //
  // options is a JSON object that can include these key/values:
  //   * message: the message for the titlebar of the Quick Signin form
  //   * reloadPage: boolean; if false, won't reload page on success
  //   * noToggle: boolean; if true, the signin won't toggle (hide/show) when it's already attached
  //
  attach: function(container, options) {
    var me = $("#quick_signin");
    var container = $(container);
    me.attr('reloadPage', options.reloadPage);

    if(me.parent()[0] == container[0]) { // if it's already attached
      if(options.noToggle) me.hide().fadeIn();
      else me.toggle();
      
      if($.quickSignIn.isHidden()) $.quickSignIn.reset();
      else me.find('input.login')[0].focus();
    } else {
      $.quickSignIn.reset();
      container.append(me);
      me.show().find(".message").html(options.message);
      me.find('input.login')[0].focus();
    }
    
    return false;
  },
  
  showSignUp: function(event) {
    me = $("#quick_signin");

    // Show default message if they click the inline signup link
    if(event && event.target.className=='inline_signup_button') me.find('div.response_container').html("<p>Choose your new user name.</p>");

    // Show signup form if hidden
    if(!me.find('.sign_up:visible').length) {
      me.find('.sign_up').show();
      me.find('input.signin_button').hide();
      me.attr('action', '/users'); // Set the forms action to /users to call UsersController#create

      if(me.find('input.login').val().match(/[^ ]+@[^ ]+/)) {
        me.find('input.email').val(me.find('input.login').val());
        me.find('input.login').val("");
      }
    }

    me.find('input.login').focus();

    return false;
  },
  
  // Updates the response section; if the response is the same as the current
  // response, it does a highlight effect on the current response.
  updateResponse: function(html) {
    resp_container = me.find('.response_container');
    if(html == resp_container.html()) resp_container.hide().fadeIn();
    else resp_container.html(html);
  }
}

// Initialize the quick sign in
$(document).ready(function(){
  $.quickSignIn.setup();
});
