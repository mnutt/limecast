// Jquery Quick Auth
// for LimeCast
jQuery.fn.extend({
  authLink: function(options) {
    this.each(function(){
      var link = $(this);

      link.mousedown(function(){
        $("#auth").toggle();
      }).click(function(){
        return false;
      });
    });
  },

  authSetup: function(options) {
    var auth = $(this);

    // Makes the form use AJAX
    auth.submit(function(event){
      auth.find('#sign_in').click();
      return false; // the form submission will be handled through specific Form Element events
    });

    auth.find('#sign_in').click(function(event){
      auth.attr('action', '/session');
      auth.find('.message').html('');
      $.post(auth.attr('action'), auth.serialize(), function(resp){
        if(resp.success) { // success, no reload
          if(resp.profileLink) { $('#nav_auth').html(resp.profileLink); }
        } else { // no success
          auth.find('.message').html(resp.html);

          // Focus the correct input
          if(/Please type your password/i.test(resp.html)) $('#user_password').focus();
          if(/Please type your email address/i.test(resp.html)) $('#user_email').focus();
        }
        return false;
      }, 'json');
      event.stopPropagation();
      return false;
    });

    // Show the full signup form on clicking the 'Sign Up' button
    auth.find('#sign_up').click(function(event){
      auth.attr('action', '/users');
      auth.find('.message').html('');
      $.post(auth.attr('action'), auth.serialize(), function(resp){
        if(resp.success) { // success, no reload
          if(resp.profileLink) { $('#nav_auth').html(resp.profileLink); }
          // $.quickSignIn.reset();

        // } else if(resp.success && me.attr('reloadPage') != 'false') { // success reload
        //   window.location.reload();
        } else { // no success
          auth.find('.message').html(resp.html);

          // Focus the correct input
          if(/Please type your password/.test(resp.html)) auth.find('#user_password').focus();
          if(/Please type your email address/.test(resp.html)) auth.find('#user_email').focus();
        }
        return false;
      }, 'json');
      event.stopPropagation();
      return false;
    });

    // me.find('.signin_button').click(function(event){
    //   if(me.find('.sign_up:visible').length) { // if signup hasn't happened yet, just show full signup form
    //     $.quickSignIn.showSignIn();
    //   }
    //   return false;
    // });

    // Handles clicking the X button to close the quick sign in box
    // me.find('a.close').click(this.reset);

    // Keypress to handle pressing escape to close box.
    // me.find('input').keydown(function(e){ if(e.keyCode == 27) $.quickSignIn.reset(); });

    auth.find('input.text')[0].focus();

    // $.quickSignIn.showOverlay();

    return auth;
  }

  // inputDefaultText: function(value, options) {
  //   options = jQuery.extend({
  //       blurColor: "#a9a9a9",
  //       focusColor: "#171717"
  //   }, options);
  // 
  //   this.each(function(){
  //     var input = $(this);
  // 
  //     var label = input.parent().find("label[for='" + input.attr("id") + "']");
  //     var defaultTxt = label.text();
  //     label.hide();
  //     
  //     var blur = function(){
  //       if (input.val() == "") {
  //         input.val(defaultTxt).css("color", options.blurColor);
  //       }
  //     }
  //     var focus = function(){
  //       if(input.val() == defaultTxt) {
  //         input.val("").css("color", options.focusColor);
  //       }
  //     };
  // 
  //     blur();
  //     input.focus(focus);
  //     input.blur(blur);
  // 
  //     input.parents('form').submit(function(){
  //       if(input.val() == defaultTxt) input.val('');
  //     });
  //   });
  // 
  //   return this;
  // }
});
