$(document).ready(function(){
  // for the podcast edit form
  $('.edit_podcast_form').map(function(){
    var show_div  = $(this);
    var edit_form = $(this).find('form.edit');

    edit_form.find('input.cancel').click(function(){
      show_div.show(); edit_form.hide();
      return false;
    });
  });

  // this is on user#show
  $('a.favorite_toggle_link').click(function(link){
    favorite_link = $(this);
    favorite_url = favorite_link.attr('href');

    $.post(favorite_url, function() {
      if(favorite_link.attr('title')=='This is a favorite.') {
        favorite_link.attr('title', 'Favorite this!').html('<img src="/images/icons/favorite.png" class="inline_icon" alt="" />Unfavorite');
      } else {
        favorite_link.attr('title', 'This is a favorite.').html('<img src="/images/icons/not_favorite.png" class="inline_icon" alt="" />Favorite');
      }
    });
    return false;

  });

  $('a.favorite_link').mustBeLoggedInBeforeSubmit({
    quick_signin: '.quick_signin.after_favoriting',
    success: function(resp) {
      $('a.favorite_link').replaceWith('<span><img src="/images/icons/favorite.png" class="inline_icon" />My Favorite</span>');
    }
  });

  $('li.review').map(function(){
    var review = $(this);
    var quick_signin = $('.quick_signin.after_rating');

    review.find('a.rate').map(function(){
      var link = $(this);

      link.click(function(){
        var copy = quick_signin.clone(true);
        copy.show()
        review.find('.quick_signin_container').html(copy);
      }).mustBeLoggedInBeforeSubmit({
        quick_signin: review.find('.quick_signin'),
        success: function(resp) {
          window.location.reload();
        }
      });
    });
  });

  $('.quick_signin.inline').quickSignIn({
    success: function(){ window.location.reload(); }
  });



});

