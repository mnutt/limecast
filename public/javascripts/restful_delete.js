$.fn.extend({
  restfulDelete: function(){
    $(this).click(function(){
      $.ajax({
        type: 'post',
        url:  $(this).attr('href'),
        data: '_method=delete&authenticity_token=' + AUTH_TOKEN
      });

      return false;
    });

    return $(this);
  }
});

