$(document).ready(function(){
  console.log("hey");

  $('form#new_review').submit(function(){
    var new_review_form = $(this);
    $.ajax({
      type:    'post',
      url:     new_review_form.attr('action'),
      data:    new_review_form.serialize(),
      dataType: "json",
      success: function(resp){
        if(resp.logged_in) {
          window.location.reload();
        } else {
          // if not logged in, show quick signin
          $.quickSignIn.attach($('.quick_signin_container.after_adding_review'), 
            {message:'Sign up or sign in to save your review:'});

          new_review_form.find('.controls').hide();
        }
      }
    });

    return false;
  });
});

