$.fn.extend({
  restfulDelete: function(opts){
    $(this).click(function(){
      var confirmed = confirm('Are you sure you want to delete this?');
 
      if(confirmed) {
        $.ajax({
          type: 'post',
          url:  $(this).attr('href'),
          data: (opts.data || {'_method':'delete'}),
          dataType: (opts.dataType || 'html'),
          success: opts.success,
          failure: opts.failure
        });
 
        if(opts.confirmed){ opts.confirmed($(this)); }
      }
 
      return false;
    });
 
    return $(this);
  }
});