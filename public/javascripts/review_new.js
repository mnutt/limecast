$(document).ready(function(){
  // XXX
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
          var html = $(resp.html);
          html.find('a.delete').restfulDelete().show(); // Show all delete links.
          $('ul.reviews').append(html);

          new_review_form.hide();
        } else {
          $('.quick_signin.after_adding_review').show();

          new_review_form.find('.controls').hide();
        }
      }
    });

    return false;
  });
});

