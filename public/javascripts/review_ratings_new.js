$(document).ready(function(){
  $('li.review').map(function(){
    var review = $(this);

    review.find('a.rate').click(function(){
      var link = $(this);
      var id = link.attr('rel');

      $.ajax({
        url: link.attr('href'),
        dataType: 'json',
        success: function(resp,ev) {
          if(resp.logged_in) {
            window.location.reload();
          } else {
            // if not logged in, show quick signin
            $.quickSignIn.attach(link.next('li.review_'+id+' .quick_signin_container.after_rating'), 
              {message:'Sign up or sign in to rate this review.'});
          }
        }
      });

      return false;
    });
  });
});

