$(document).ready(function(){
  console.log("hey");

  $('form#new_review').submit(function(){
    var new_review_form = $(this);
  console.log("hey");
  console.log($(this).attr('action'));
  console.log($(this).serialize());
    $.ajax({
      type:    'post',
      url:     $(this).attr('action'),
      data:    $(this).serialize(),
      dataType: "json",
      complete: function(resp){ console.log(resp.responseText);// for(var i in resp){ console.log(resp[i]); console.log(i); }
      },
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

