// Jquery Quick Auth
// for LimeCast
jQuery.fn.extend({
  authLink: function(options) {
    this.each(function(){
      var link = $(this);

      link.mousedown(function(){
        $("#auth").authOverlay().show().find("#user_email").focus();
        return false;
      }).click(function(){ return false; });

      return link;
    });
  },
  
  authOverlay: function() {
    if($("#authOverlay").size() == 0) $('body').append('<div id="authOverlay"></div>');
    $("#authOverlay").mousedown(function(){
      $("#auth").authReset();
      $(this).remove();
    }).css('height', $('body').attr('clientHeight')+'px');;
    return $(this);
  },
  
  authReset: function() { $(this).hide().find('.message').html('<a href="/forgot">I forgot my password</a>').end().find('form')[0].reset(); },
  
  authSetup: function(options) {
    var auth_form = $(this);

    // Enable X button & esc to close auth
    $("#auth .close").mousedown(function(){ $("#auth").authReset(); return false; });
    auth_form.find('input').keydown(function(e){ if(e.keyCode == 27) $("#auth").authReset(); })

    // Makes the form use AJAX
    auth_form.submit(function(event){
      auth_form.find('#sign_in').click();
      return false; // the form submission will be handled through specific Form Element events
    });

    var callback = function(event){
      auth_form.attr('action', ($(this).attr('id') == 'sign_up' ? '/users' : '/session'));
      $.post(auth_form.attr('action'), auth_form.serialize(), function(resp){
        if(resp.success) { // success, no reload
          if(resp.profileLink) { 
            $("#authOverlay").remove();
            $('#nav_auth').html(resp.profileLink);
            $('#auth').authReset();
            $("#sign_out_link").signoutSetup();
          } else window.location.reload();
        } else { // no success
          auth_form.find('.message').html(resp.html);
          auth_form.effect('shake', { times:1, distance:5 }, 25, function(){ 
            // Focus the correct input
            if(/type your password/i.test(resp.html)) $('#user_password').focus();
            else $('#user_email').focus();
          });
        }
      }, 'json');
      event.stopPropagation();
      return false;
    };

    auth_form.find('#sign_in').click(callback);
    auth_form.find('#sign_up').click(callback);

    auth_form.find('input.text')[0].focus();

    return auth_form;
  },

  signoutSetup: function() {
    // Enable signout link
    $(this).click(function(e){
      $.post($(this).attr('href'), {_method:'delete'}, function(res){ 
        $("#nav_auth").html(res);
        $("#auth_link").authLink();
        $("#auth form").authSetup();
      });
      e.stopPropagation();
      return false;
    });
  }

});
