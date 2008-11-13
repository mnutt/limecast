$(document).ready(function(){
  $('.quick_signin.inline').quickSignIn({
    success: function(){ window.location.reload(); }
  });

  $('form#new_comment').submit(function(){
    var new_comment_form = $(this);
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
          $('.quick_signin.inline').show();
        }

        new_comment_form.hide();
      }
    });

    return false;
  });
});

