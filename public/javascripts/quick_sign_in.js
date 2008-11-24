$.fn.extend({
  quickSignIn: function(opts) {
    if(opts.ajax == null) { opts.ajax = true; }

    var me = $(this);

    me.find('input.signup_button').click(function(){
      // We only want to submit the form if the sign in button is no longer there.
      var should_submit = me.find('input.signin_button').css('display') == 'none';

      if(!opts.ajax) {
        // Set password message and focus password field if it is left blank
        if(me.find('input.password').val() == "") {
          me.find('div.response_container').text("Please choose a password");
          me.find('input.password').focus();
        }
        
        // Set username message and focus username field if it is left blank
        if(me.find('input.login').val() == "") {
          me.find('div.response_container').text("Choose your new user name");
          me.find('input.login').focus();
        }
      } else {
        $.ajax({
          type:    'post',
          url:     me.find('form').attr('action'),
          data:    me.find('form').serialize(),
          dataType: "json",
          success: function(resp){
            if(resp.success) {
              window.location.reload();
            } else {
              if(resp.html.match(/User and password don't match/)) 
                me.find('div.response_container').html(resp.html);
              me.find('.sign_up').show();
              me.find('.sign_up input').focus();
              me.find('input.signin_button').hide();
            }
          }
        });
      }

      // Set the forms action to /users to call UsersController#create
      me.find('form').attr('action', '/users');

      return should_submit;
    });

    if(opts.ajax) {
      me.find('form').bind('submit', function(){
        $.ajax({
          type:    'post',
          url:     $(this).attr('action'),
          data:    $(this).serialize(),
          dataType: "json",
          success: function(resp){
            if(resp.success) {
              window.location.reload();
            } else {
              response_container = me.find('.response_container');
              if(resp.html == response_container.html()) {
                me.find('.response_container').hide();
                me.find('.response_container').html(resp.html);
                me.find('.response_container').fadeIn();
              } else me.find('.response_container').html(resp.html);
            }

            // Call handlers
            if(resp.success && opts.success) { opts.success(resp); }
            if(!resp.success && opts.error)  { opts.error(resp); }
          }
        });

        return false;
      });
    }

    return $(this);
  }
});

