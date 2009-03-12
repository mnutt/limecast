$.quickSignIn = {
  isHidden: function()  { return ($("#quick_signin").css('display') == 'none'); },
  isVisible: function() { return ($("#quick_signin").css('display') != 'none'); },

  setup: function() {
    var me = $("#cluetip #quick_signin");

    // Makes the form use AJAX
    me.submit(function(event){
      if(!me.find('.sign_up:visible').length) 
        me.find('.signin_signup_button').click();
      else
        me.find('.signin_signup_button').click();
      return false; // this will all be handled through specific Form Element events
    });
    
    me.find('.signin_signup_button').click(function(event){
      if(!me.find('.sign_up:visible').length) { // if signup hasn't happened yet, just show full signup form
        $.post(me.attr('action'), me.serialize(), $.quickSignIn.signinSubmitCallback, 'json');
      } else {
        $.post(me.attr('action'), me.serialize(), $.quickSignIn.signupSubmitCallback, 'json');
      }
    });
    
    // Show the full signup form on clicking the 'Sign Up' button
    me.find('.signup_button').click(function(event){
      if(!me.find('.sign_up:visible').length) { // if signup hasn't happened yet, just show full signup form
        $.quickSignIn.showSignUp();
      }
      return false;
    });

    me.find('.signin_button').click(function(event){
      if(me.find('.sign_up:visible').length) { // if signup hasn't happened yet, just show full signup form
        $.quickSignIn.showSignIn();
      }
      return false;
    });
    
    // Handles clicking the X button to close the quick sign in box
    me.find('a.close').click(this.reset);

    // Keypress to handle pressing escape to close box.
    me.find('input').keydown(function(e){ if(e.keyCode == 27) $.quickSignIn.reset(); }); 

    me.find('input#quicksignin_login').focus();

    $.quickSignIn.showOverlay();

    return me;
  },
  
  signinSubmitCallback: function(resp){
    me = $("#cluetip #quick_signin");

    if(resp.success && me.attr('reloadPage') == 'false') { // success, no reload
      for(var a in resp) {
        console.log(resp[a]);
      }
      if(resp.profileLink) { $('#utility_nav').html(resp.profileLink); }
      $.quickSignIn.reset();

    } else if(resp.success && me.attr('reloadPage') != 'false') { // success reload
      window.location.reload(); 
    } else { // no success
      $.quickSignIn.updateResponse(resp.html);

      // If the user tried to signin with unknown creds
      if(/Please type your email address/.test(resp.html)) {
        $.quickSignIn.showSignUp();
        me.find('input.email').focus();
      }

      // attach event to 'Are you trying to Sign Up?' link
      me.find('.inline_signup_button').click($.quickSignIn.showSignUp);
    }
    return false;
  },

  signupSubmitCallback: function(resp){
    me = $("#cluetip #quick_signin");

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
    me = $("#cluetip #quick_signin");
    me.find('.message').html('');
    me.find('.sign_up').hide();
		me.find('.controls').show();
		me.find('.controls_signup').hide();
		me.find('.signup_heading').text('Sign in to LimeCast');
		me.find('.signin_signup_button span').text('Sign in');
    me.attr('action', '/session');
//    me.find('form')[0].reset(); // the actual DOM function for resetting a form
    me.find('div.response_container').html('');
  },

  // Attaches the Quick Signin form to a container
  //
  // options is a JSON object that can include these key/values:
  //   * message: the message for the titlebar of the Quick Signin form
  //   * reloadPage: boolean; if false, won't reload page on success
  //   * toggle: boolean; if true, the signin will toggle (hide/show) when it's already attached
  //
  attach: function(container, options) {
    var me = $("#cluetip #quick_signin");
    var container = $(container);
    me.attr('reloadPage', options.reloadPage);

    // if(me.parent()[0] == container[0]) { // if it's already attached
    //   if(options.toggle) me.toggle();
    //   else me.show();
    //   
    //   if(me.css('display')=='none') $.quickSignIn.reset();
    //   else me.find('input.login')[0].focus();
    // } else {
      $.quickSignIn.reset();
      container.append(me);
      me.show().find(".message").html(options.message);
      me.find('input#user_login').focus();
    // }
    
    return false;
  },
  
  showSignUp: function(event) {
    me = $("#cluetip #quick_signin");

    // Show default message if they click the inline signup link
    if(event && event.target.className=='inline_signup_button') me.find('div.response_container').html("<p>Choose your new user name.</p>");

    // Show signup form if hidden
    if(!me.find('.sign_up:visible').length) {
      me.find('.sign_up').show();
			me.find('.signup_heading').text('Sign up with LimeCast');
			me.find('.controls').hide();
			me.find('.controls_signup').show();
      me.find('.signin_signup_button span').text('Sign up');
      me.attr('action', '/users'); // Set the forms action to /users to call UsersController#create

      if(me.find('input.login').val().match(/[^ ]+@[^ ]+/)) {
        me.find('input.email').val(me.find('input.login').val());
        me.find('input.login').val("");
      }
    }
    me.find('input#user_login').focus();    

    return false;
  },

  showSignIn: function(event) {
    me = $("#cluetip #quick_signin");

    // Show default message if they click the inline signup link
    if(event && event.target.className=='inline_signup_button') me.find('div.response_container').html("<p>Choose your new user name.</p>");

    // Show signup form if hidden
    if(me.find('.sign_up:visible').length) {
      me.find('.sign_up').hide();
			me.find('.signup_heading').text('Sign in to LimeCast');
			me.find('.controls').show();
			me.find('.controls_signup').hide();
      me.find('.signin_signup_button span').text('Sign in');
      me.attr('action', '/session'); // Set the forms action to /users to call UsersController#create
    }
    me.find('input.login').focus();

    return false;
  },
  
  // similar to jquery.dropdown.js
  showOverlay: function() {
    if($("#overlay").size() == 0) $('body').append("<div id=\"overlay\"></div>");
    $("#overlay").mousedown(function(){
      $('#cluetip-close').click();
      $(this).remove();
    }).css('height', $('body').attr('clientHeight')+'px');
    $("#cluetip-close").click($.quickSignIn.reset);
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
// $(document).ready(function(){
//   $.quickSignIn.setup();
// });
