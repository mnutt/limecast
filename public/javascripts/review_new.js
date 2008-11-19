$(document).ready(function(){
  $('.quick_signin.inline').quickSignIn({
    success: function(){ window.location.reload(); }
  });

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
        } else {
          $('.quick_signin.after_adding_review').show();
        }

        new_review_form.hide();
      }
    });

    return false;
  });
});

