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
            
          }

          // Call handlers
          if(resp.success && opts.success) { opts.success(resp); }
          if(!resp.success && opts.error)  { opts.error(resp); }
        }
      });

      return false;
    });

    return $(this);
  }
});

