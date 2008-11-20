// Create some sort of signin proxy before the form actually gets posted. That will allow me
// to remove all of the code that associates things with a session after a person logs in.
$.fn.extend({
  mustBeLoggedInBeforeSubmit: function(opts){
    var link = $(this);

    link.click(function(){
      $.ajax({
        url: link.attr('href'),
        dataType: 'json',
        success: function(resp) {
          if(resp.logged_in) {
            if(opts.success) {
              opts.success(resp);
            }
          } else {
            $(opts.quick_signin).find('.message').html("<p>"+resp.message+"</p>");
            $(opts.quick_signin).show();
          }
        }
      });
  
      return false;
    });
  }
});
