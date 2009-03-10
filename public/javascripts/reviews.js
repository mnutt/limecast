$(document).ready(function(){
  // review rating links
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
            $.quickSignIn.attach($('li#review_'+id+' .quick_signin_container.after_rating'), 
              {message:'Sign up or sign in to rate this review.'});
          }
        }
      });

      return false;
    });
  });


  // review form toggle
  $('.review a.edit').live('click', function(){
    alert('me');
    $(this).parents('.review').find('.show_review').hide();
    $(this).parents('.review').find('.edit_review').show();
  });
    // 
    // 
    // $('li.review, div.review').map(function(){
    //   var show  = $(this).find('.show_review');
    //   var edit = $(this).find('.edit_review');
    // 
    //   show.find('a.edit').click(function(){
    //     show.hide(); edit.show(); return false;
    //   });
    // 
    //   edit.find('a.cancel').click(function(){
    //     show.show(); edit.hide(); return false;
    //   });
    // });  

  // review form ajax
  $('.review_form').live('submit', function(){
    var review_form = $(this);
    $.ajax({
      type:    'post',
      url:     review_form.attr('action'),
      data:    review_form.serialize(),
      dataType: 'json',
      success: function(resp){
        if(resp.success) {
          if(resp.login_required) {
            alert('login required');
            // // if not logged in, show quick signin
            // $.quickSignIn.attach($('.quick_signin_container.after_adding_review'), 
            //   {message:'Sign up or sign in to save your review:'});
          } else { 
            review_form.parents('.review').replaceWith(resp.html);
          };
        } else {
          review_form.find('.errors').html(resp.errors).show();
        }
      }
    });

    return false;
  });
});

