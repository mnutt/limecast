jQuery.fn.extend({
  quickSignIn: function(opts) {
    var me = $(this);

    me.find('input.signup_button').click(function(){
      // We only want to submit the form if the sign in button is no longer there.
      var should_submit = me.find('input.signin_button').css('display') == 'none';

      me.find('.sign_up').show();
      me.find('.sign_up input').focus();
      me.find('input.signin_button').hide();

      // Set the forms action to /users to call UsersController#create
      me.find('form').attr('action', '/users');

      return should_submit;
    });

    me.find('form').bind('submit', function(){
      jQuery.ajax({
        type:    'post',
        url:     jQuery(this).attr('action'),
        data:    jQuery(this).serialize(),
        dataType: "json",
        success: function(resp){
          // Call handlers
          if(resp.success && opts.success) { opts.success(resp); }
          if(!resp.success && opts.error)  { opts.error(resp); }
        }
      });

      return false;
    });

    return jQuery(this);
  }
});

