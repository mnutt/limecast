$.fn.extend({
  restfulDelete: function(opts){
    $(this).click(function(){
      if(opts.confirm) {
	var confirmed = confirm(opts.confirm);
      } else {
	var confirmed = confirm('Are you sure you want to delete this?');
      }
      if(confirmed) {
        $.ajax({
          type: 'post',
          url:  $(this).attr('href'),
	  success: opts.success,
          data: '_method=delete&authenticity_token=' + AUTH_TOKEN
        });

        if(opts.confirmed){ opts.confirmed(); }
      }

      return false;
    });

    return $(this);
  }
});

