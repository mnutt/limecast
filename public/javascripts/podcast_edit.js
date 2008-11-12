jQuery(document).ready(function(){
  $('.edit_podcast_form').map(function(){
    var show_div  = $(this);
    var edit_form = $(this).find('form.edit');

    edit_form.find('input.cancel').click(function(){
      show_div.show(); edit_form.hide();
      return false;
    });
  });

  // this is on user#show
  jQuery('a.favorite_toggle_link').click(function(link){
    favorite_link = jQuery(this);
    favorite_url = favorite_link.attr('href');

    jQuery.post(favorite_url, function() {
      if(favorite_link.attr('title')=='This is a favorite.') {
        favorite_link.attr('title', 'Favorite this!').html('<img src="/images/icons/favorite.png" class="inline_icon" alt="" />Unfavorite');
      } else {
        favorite_link.attr('title', 'This is a favorite.').html('<img src="/images/icons/not_favorite.png" class="inline_icon" alt="" />Favorite');
      }
    });
    return false;

  });

  // this is on podcast#show
  jQuery('a.favorite_link').click(function(link){
    favorite_link = jQuery(this);
    favorite_url = favorite_link.attr('href');

    jQuery.post(favorite_url, function() {
      favorite_link.replaceWith('<span><img src="/images/icons/favorite.png" class="inline_icon" />My Favorite</span>');
    });
    return false;

  });


});

