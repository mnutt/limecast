$.fn.extend({
  quickSignIn: function(opts) {
    var me = $(this);

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
            
            if(!opts.error) { opts.error(resp); }
          }
        }
      });

      return false;
    });

    me.find('form .signup_button').bind('click', function(event){
      console.log(event.detail);
      if (me.find('form input.signin_button:visible') && event.detail > 0 ) { // event.detail = # of mouse clicks
        me.showQuickSignUpForm();
        return false;
      }
    });

    return $(this);
  },
  showQuickSignUpForm: function() {
    me = $(this);
    me.find('.sign_up').show();
    me.find('input.login').focus();
    me.find('input.signin_button').hide();
    me.find('form').attr('action', '/users'); // Set the forms action to /users to call UsersController#create

    if(me.find('input.login').val().match(/[^ ]+@[^ ]+/)) {
      me.find('input.email').val(me.find('input.login').val());
      me.find('input.login').val("");
    }
    me.find('div.response_container').html("<p>Please choose your new user name.</p>");
  }
});

