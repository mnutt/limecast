// Jquery Quick Auth
// for LimeCast
jQuery.fn.extend({
  authLink: function(options) {
    this.each(function(){
      var link = $(this);

      link.mousedown(function(){
        $("#auth").toggle().find("#user_email").focus();
        return false;
      }).click(function(){
        return false;
      });
    });
  },

  authSetup: function(options) {
    var auth_form = $(this);

    // Enable X button & esc to close auth
    $("#auth .close").mousedown(function(){ $("#auth").toggle(); return false; });
    auth_form.find('input').keydown(function(e){ if(e.keyCode == 27) $("#auth").toggle(); return false; });

    // Makes the form use AJAX
    auth_form.submit(function(event){
      auth_form.find('#sign_in').click();
      return false; // the form submission will be handled through specific Form Element events
    });

    var callback = function(event){
      auth_form.attr('action', ($(this).attr('id') == 'sign_up' ? '/users' : '/session'));
      auth_form.find('.message').html('');
      $.post(auth_form.attr('action'), auth_form.serialize(), function(resp){
        if(resp.success) { // success, no reload
          if(resp.profileLink) { $('#nav_auth').html(resp.profileLink); }
          // window.location.reload();
        } else { // no success
          auth_form.find('.message').html(resp.html);
          auth_form.effect("shake", { times:1, distance: 5 }, 50);
          
          // Focus the correct input
          if(/Please type your password/i.test(resp.html)) $('#user_password').focus();
          else $('#user_email').focus();
          $('#user_email').focus();
        }
 //       return false;
      }, 'json');
      event.stopPropagation();
      return false;
    };

    auth_form.find('#sign_in').click(callback);
    auth_form.find('#sign_up').click(callback);

    // me.find('.signin_button').click(function(event){
    //   if(me.find('.sign_up:visible').length) { // if signup hasn't happened yet, just show full signup form
    //     $.quickSignIn.showSignIn();
    //   }
    //   return false;
    // });


    auth_form.find('input.text')[0].focus();

    // $.quickSignIn.showOverlay();

    return auth_form;
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
