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

  // this is on podcast#show
  $('a.favorite_link').click(function(link){
    favorite_link = $(this);
    favorite_url = favorite_link.attr('href');
    $.post(favorite_url, {}, function(resp) {
      if(resp.logged_in) {
        favorite_link.replaceWith('<span><img src="/images/icons/favorite.png" class="inline_icon" />My Favorite</span>');
      } else {
        $('.quick_signin.after_favoriting .message').html("<p>"+resp.message+"</p>");
        $('.quick_signin.after_favoriting').show();
      }
    }, "json");

    return false;
  });

  $('.quick_signin.inline').quickSignIn({
    success: function(){ window.location.reload(); }
  });

});

