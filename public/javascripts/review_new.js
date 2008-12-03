$(document).ready(function(){

  $('form#new_review').submit(function(){
    var new_review_form = $(this);
    $.ajax({
      type:    'post',
      url:     $(this).attr('action'),
      data:    $(this).serialize(),
      dataType: "json",
      success: function(resp){
        if(resp.logged_in) {
          $('ul.reviews').append(resp.html);
          $('a.delete').show(); // Show all delete links.

          new_review_form.hide();
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

