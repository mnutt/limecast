jQuery.fn.extend({
  quickSignIn: function(opts) {
    if(opts.ajax == null) { opts.ajax = true; }

    var me = jQuery(this);

    me.find('input.signup_button').click(function(){
      // We only want to submit the form if the sign in button is no longer there.
      var should_submit = me.find('input.signin_button').css('display') == 'none';

      me.find('.sign_up').show();
      me.find('.sign_up input').focus();
      me.find('input.signin_button').hide();

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

      // Set the forms action to /users to call UsersController#create
      me.find('form').attr('action', '/users');

      return should_submit;
    });

    if(opts.ajax) {
      me.find('form').bind('submit', function(){
        jQuery.ajax({
          type:    'post',
          url:     jQuery(this).attr('action'),
          data:    jQuery(this).serialize(),
          dataType: "json",
          success: function(resp){
            if(resp.success) {
              jQuery('#account_bar .signup').html(resp.html);
            } else {
              me.find('.response_container').html(resp.html);
            }

            // Call handlers
            if(resp.success && opts.success) { opts.success(resp); }
            if(!resp.success && opts.error)  { opts.error(resp); }
          }
        });

        return false;
      });
    }

    return jQuery(this);
  }
});

