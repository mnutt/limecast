$(document).ready(function(){
  $('li.review').map(function(){
    var review = $(this);

    review.find('a.rate').map(function(){
      $(this).mustBeLoggedInBeforeSubmit({
        quick_signin: review.find('.quick_signin'),
        success: function(resp) {
          window.location.reload();
        }
      });
    });
  });

  // FIX
  // $('.quick_signin.inline').quickSignIn({
  //   success: function(){ window.location.reload(); }
  // });
});

