jQuery.fn.extend({
  restfulDelete: function(){
    jQuery(this).click(function(){
      jQuery.ajax({
        type: 'post',
        url:  jQuery(this).attr('href'),
        data: '_method=delete&authenticity_token=' + AUTH_TOKEN
      });

      return false;
    });

    return jQuery(this);
  }
});

